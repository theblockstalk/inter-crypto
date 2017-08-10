pragma solidity ^0.4.15;

// import "github.com/ugmo04/inter-crypto/contracts/InterCrypto_Interface.sol";
import "./InterCrypto_Interface.sol";

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

    function InterCrypto_Wallet() {
        owner = msg.sender;
    }

    function () payable {
    }

    function deposit() payable {
      if (msg.value > 0) {
          funds[msg.sender] += msg.value;
          Deposit();
      }
    }

    function intercrypto_GetInterCryptoPrice() constant public returns (uint) {
        return interCrypto.getInterCryptoPrice();
    }

    function withdrawalNormal() isOwner external {
        WithdrawalNormal();
        msg.sender.transfer(this.balance);
    }

    function withdrawalInterCrypto(string _coinSymbol, string _toAddress) external payable {
        uint amount = funds[msg.sender];
        funds[msg.sender] = 0;
        uint transactionID = interCrypto.sendToOtherBlockchain.value(amount + msg.value)(_coinSymbol, _toAddress);
        WithdrawalInterCrypto(transactionID);
    }


    function intercrypto_Recover() isOwner external {
        interCrypto.recover();
    }

    function intercrypto_amountRecoverable() isOwner public constant returns (uint) {
        return interCrypto.amountRecoverable();
    }

    function kill() isOwner external {
        selfdestruct(owner);
    }
}
