//https://www.youtube.com/watch?v=1IDqOXRF-Ls
//https://www.youtube.com/watch?v=lQtf6mI1D70&t=160s

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {

  struct Staker {
        uint stakedTokens;
        uint lastStakeMovement;
    }

    mapping(address => Staker) public balances;
    uint public basisPoints;
    IERC20 public token;

    event Stake(address _staker, uint _stakedTokens);
    event Unstake(address _staker, uint _unstakedTokens);
    event Print(string _message, uint256 _reward);

    constructor(uint _basisPoints)ERC20("THREE", "THR"){ 
        basisPoints = _basisPoints;
        _mint(address(this), 1000000000000000000);
        _mint(0x7dC329c73a29c2E6606670c9F03B38976DE4E328, 1000);
        token = IERC20(address(this));
    }

    function stake(uint256 _numTokens) external {
        require(balanceOf(msg.sender) >= _numTokens, "Not enough balance");

        _transfer(msg.sender, address(this), _numTokens);

        balances[msg.sender].stakedTokens += _numTokens;
        balances[msg.sender].lastStakeMovement = block.timestamp;

        emit Stake(msg.sender, _numTokens);
    }

    function unstake(uint256 _numTokens)external{
        require(balances[msg.sender].stakedTokens >= _numTokens, "Insufficient staked tokens");
        balances[msg.sender].stakedTokens -= _numTokens;
        _transfer(address(this), msg.sender, _numTokens);

        emit Unstake(msg.sender, _numTokens);
    }

    function calculateReward(address _staker) public view returns (uint256){
        Staker storage staker = balances[_staker];

        uint256 timeDiff = block.timestamp - staker.lastStakeMovement; //diferencia de tiempo en s
        uint256 apr = calculateAPR();//apr basada en basisPoints
        uint256 stakingReward = (staker.stakedTokens * apr * timeDiff) / (86400 * 1e18);//*

        return stakingReward;
    }

    function calculateAPR()internal view returns(uint256){
        return basisPoints * 1e18 / 10000; 
    }

    function claimReward()external returns (bool){
        uint256 reward = calculateReward(msg.sender);
        require(reward > 0, "No rewards available");
        balances[msg.sender].lastStakeMovement = block.timestamp;
        require(token.transfer(msg.sender, reward), "Transaction Failed.");
        return true;
    }
}
// Main: 0x7dC329c73a29c2E6606670c9F03B38976DE4E328
// Test: 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2