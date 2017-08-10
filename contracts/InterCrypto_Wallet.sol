pragma solidity ^0.4.4;

import "github.com/ugmo04/inter-crypto/contracts/InterCrypto_Interface.sol";

contract InterCrypto_Wallet is usingInterCrypto {

    event Deposit();
    event WithdrawalNormal();
    event WithdrawalInterCrypto(uint transactionID);

    address owner;
    mapping (address => uint) funds;

    modifier isOwner() {
        require(msg.sender == owner);
        _;
    }

    function InterCrypto_Demo() {
        owner = msg.sender;
    }

    function () payable {
      if (msg.value > 0) {
          funds[msg.sender] += msg.value;
          Deposit();
      }
    }

    function intercrypto_GetInterCryptoPrice() constant public returns (uint) {
        return interCrypto.getInterCryptoPrice();
    }

    function withdrawNormal() isOwner external {
        WithdrawalNormal();
        msg.sender.transfer(this.balance);
    }

    function intercrypto_SendToOtherBlockchain(string _coinSymbol, string _toAddress) external payable {
        funds[msg.sender] = 0;
        uint transactionID = interCrypto.sendToOtherBlockchain.value(funds[msg.sender] + msg.value)(_coinSymbol, _toAddress);
        WithdrawalInterCrypto(transactionID);
    }


    function intercrypto_Recover() isOwner public {
        interCrypto.recover();
    }

    function kill() isOwner external {
        selfdestruct(owner);
    }
}
