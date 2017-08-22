pragma solidity ^0.4.15;

import "github.com/ugmo04/inter-crypto/contracts/InterCrypto_Interface.sol";
// import "./InterCrypto_Interface.sol";

contract InterCrypto_Wallet is usingInterCrypto {

event Deposit(address indexed deposit, uint amount);
event WithdrawalNormal(address indexed withdrawal, uint amount);
event WithdrawalInterCrypto(uint indexed conversionID);

mapping (address => uint) public funds;

function InterCrypto_Wallet() {}

function () payable {}

function deposit() payable {
  if (msg.value > 0) {
      funds[msg.sender] += msg.value;
      Deposit(msg.sender, msg.value);
  }
}

function intercrypto_getInterCryptoPrice() constant public returns (uint) {
    return interCrypto.getInterCryptoPrice();
}

function withdrawalNormal() payable external {
    uint amount = funds[msg.sender] + msg.value;
    funds[msg.sender] = 0;
    if(msg.sender.send(amount)) {
        WithdrawalNormal(msg.sender, amount);
    }
    else {
        funds[msg.sender] = amount;
    }
}

function withdrawalInterCrypto(string _coinSymbol, string _toAddress) external payable {
    uint amount = funds[msg.sender] + msg.value;
    funds[msg.sender] = 0;
    uint conversionID = intercrypto_convert(amount, _coinSymbol, _toAddress);
    WithdrawalInterCrypto(conversionID);
}


function intercrypto_recover() onlyOwner public {
    interCrypto.recover();
}

function intercrypto_recoverable() constant public returns (uint) {
    return interCrypto.recoverable(this);
}

function intercrypto_cancelConversion(uint conversionID) onlyOwner external {
    interCrypto.cancelConversion(conversionID);
}

function kill() onlyOwner external {
    selfdestruct(owner);
}
}
