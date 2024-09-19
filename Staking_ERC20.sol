// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

contract Staking_ERC20 {

    struct Staker {
        uint amount;
        uint staked_timestamp;
    }

    mapping(address => Staker) public balances;
    uint public APR_bp;

    event Stake(address _staker, uint _amount);
    event Withdraw(address _staker, uint stake_amount);

    constructor(uint _APR){ // basis points = 5000 para 5%
        APR_bp = _APR;
    }

    function getBalance(address _staker) public view returns(uint) {
        return balances[_staker].amount;
    }

    function calculateStakePercentage() private view returns(uint) {
        return APR_bp / 1000;
    }

    function stake(address _staker, uint _amount) public {
        require(_staker==msg.sender, "Not the owner of the staking.");
        balances[_staker] = Staker({amount:_amount, staked_timestamp:block.timestamp});
        emit Stake(_staker, _amount);
    }

    function calculateTimePassed(uint _time_diff) private pure returns(uint) {
        uint days_time = _time_diff / 86400; // 86400 seconds in a day
        return (days_time / 30) /12;
        
    }

    function calculateFinalValue(address _staker, uint _years, uint _stake_percentage) private view returns(uint) {
        // CF = C * (1+((n*r)/100))
        return balances[_staker].amount * (1+((_years*_stake_percentage)/100));
    }

    function withdraw(address _staker) public returns(uint) {
        require(_staker==msg.sender, "Not the owner of the staking.");
        
        uint time_diff = block.timestamp - balances[_staker].staked_timestamp;
        uint years_time = calculateTimePassed(time_diff);
        // time_diff/31556952
        uint stake_percentage = calculateStakePercentage();
        uint staking_amount = calculateFinalValue(_staker, years_time, stake_percentage);
        
        balances[_staker].amount = 0;
        balances[_staker].staked_timestamp = 0;

        emit Withdraw(_staker, staking_amount);
        
        return staking_amount;
    }

    function withdraw_test(address _staker, uint _period) public returns(uint) {
        require(_staker==msg.sender, "Not the owner of the staking.");
        
        
        uint stake_percentage = calculateStakePercentage();
        
        uint staking_amount = calculateFinalValue(_staker, _period, stake_percentage);
        
        balances[_staker].amount = 0;
        balances[_staker].staked_timestamp = 0;

        emit Withdraw(_staker, staking_amount);
        
        return staking_amount;
    }

}