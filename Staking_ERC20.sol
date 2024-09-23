// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/*
* @notice Hace staking de tokens
* @dev Permite al owner definir el porcentaje de staking con base
* en basis points
*/
contract StakingContract is ERC20 {

  struct Staker {
        uint stakedTokens;
        uint lastStakeMovement;
    }

    //mapping que relaciona la direccion del usuario con
    //los tokens bloqueadas y la fecha y hora de la ultima transaccion
    mapping(address => Staker) public balances;
    
    uint public basisPoints;

    event Stake(address _staker, uint _stakedTokens);
    event Unstake(address _staker, uint _unstakedTokens);

    constructor(uint _basisPoints)ERC20("THREE", "THR"){ 
        basisPoints = _basisPoints;
        _mint(msg.sender, 1 * 10 ** 18);
    }

    /*
    * @notice Bloquea tokens para hacer staking
    * @param _numTokens Numero de tokens que seran bloqueados para el staking
    */
    function stake(uint256 _numTokens) external {
        require(balanceOf(msg.sender) >= _numTokens, "Not enough balance");

        _transfer(msg.sender, address(this), _numTokens);

        //registra la cantidad de tokens bloqueados
        balances[msg.sender].stakedTokens += _numTokens;
        
        //registra la fecha y hora en que se bloquean los toques, en segundos
        balances[msg.sender].lastStakeMovement = block.timestamp;

        emit Stake(msg.sender, _numTokens);
    }

    /*
    * @notice Desbloque tokens
    * @dev Devuelve los toques bloqueados en el contrato hacia el 
    * usuario
    * @param _numTokens Numero de tokens que serán desbloqueados y devueltos
    */
    function unstake(uint256 _numTokens)external{
        require(balances[msg.sender].stakedTokens >= _numTokens, "Insufficient staked tokens");
        balances[msg.sender].stakedTokens -= _numTokens;
        _transfer(address(this), msg.sender, _numTokens);

        emit Unstake(msg.sender, _numTokens);
    }

    /*
    * @notice Calcula la recompensa por los tokens en staking
    * @param _staker Direccion del usuario
    * @returns Numero de tokens ganados por el staking
    */
    function calculateReward(address _staker) public view returns (uint256){
        Staker storage staker = balances[_staker];

        //diferencia de tiempo en segundos entre el tiempo de solicitar
        //la recompensa y el momento de staking mas reciente
        uint256 timeDiff = block.timestamp - staker.lastStakeMovement; 
        
        //apr basada en basisPoints
        uint256 apr = calculateAPR();

        uint256 stakingReward = (staker.stakedTokens * apr * timeDiff) / (365 days * 1e18);

        return stakingReward;
    }

    /*
    * @notice Calcula el Annual Percentage Rate 
    * @dev Se calcula basos en basis points
    * @returns Annual Percentage Rate 
    */
    function calculateAPR()internal view returns(uint256){
        return basisPoints * 1e18 / 10000; 
    }

    /*
    * @notice Reclama la ganancia obtenida con el staking
    * @dev A partir de la recompensa se crea (mint) tokens para poder transferiral usuario
    */
    function claimReward()external payable returns (bool){
        uint256 reward = calculateReward(msg.sender);
        require(reward > 0, "No rewards available");
        balances[msg.sender].lastStakeMovement = block.timestamp;
        _mint(msg.sender, reward);
        return true;
    }
}