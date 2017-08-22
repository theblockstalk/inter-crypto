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

function intercrypto_GetInterCryptoPrice() constant public returns (uint) {
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
    uint amount = funds[msg.sender];
    funds[msg.sender] = 0;
    uint conversionID = intercrypto_convert(amount + msg.value, _coinSymbol, _toAddress);
    WithdrawalInterCrypto(conversionID);
}


function intercrypto_Recover() onlyOwner external {
    interCrypto.recover();
}

function intercrypto_Recoverable() public constant returns (uint) {
    return interCrypto.recoverable(this);
}

function kill() onlyOwner external {
    selfdestruct(owner);
}
}
