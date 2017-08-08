pragma solidity ^0.4.4;

import "github.com/ugmo04/inter-crypto/contracts/InterCryptoAPI.sol";
// import "./InterCryptoAPI.sol";

contract InterCrypto_Demo is usingInterCrypto {

    // event Transaction(uint transactionID);
    event Deposit();
    event WithdrawalNormal();
    event WithdrawalInterCrypto(uint transactionID);

    // function goodSendToOtherBlockchain() external payable{
    //     uint transactionID = interCrypto.sendToOtherBlockchain.value(msg.value)('ltc', 'LbZcDdMeP96ko85H21TQii98YFF9RgZg3D');
    //     Transaction(transactionID);
    // }

    // function notEnoughEtherSendToOtherBlockchain() external payable{
    //     uint transactionID = interCrypto.sendToOtherBlockchain.value(1)('ltc', 'LbZcDdMeP96ko85H21TQii98YFF9RgZg3D');
    //     Transaction(transactionID);
    // }

    // function badSymbolEtherSendToOtherBlockchain() external payable{
    //     uint transactionID = interCrypto.sendToOtherBlockchain.value(msg.value)('lt c', 'LbZcDdMeP96ko85H21TQii98YFF9RgZg3D');
    //     Transaction(transactionID);
    // }

    // function badAddresslEtherSendToOtherBlockchain() external payable{
    //     uint transactionID = interCrypto.sendToOtherBlockchain.value(msg.value)('ltc', 'LbZcDdMeP96ko 85H21TQii98YFF9RgZg3D');
    //     Transaction(transactionID);
    // }

    // function withdrawInterCrypto() {
    //     interCrypto.recover();
    // }

    // uint public ethSum;
    address owner;

    modifier isOwner() {
        require(msg.sender == owner);
        _;
    }

    function InterCrypto_Demo() {
        owner = msg.sender;
    }

    function () payable {
    //   ethSum += msg.value;
      if (msg.value > 0)
        Deposit();
    }

    function intercrypto_GetInterCryptoPrice() constant public returns (uint) {
        return interCrypto.getInterCryptoPrice();
    }

    function withdrawNormal() isOwner external {
        WithdrawalNormal();
        msg.sender.transfer(this.balance);
    }

    function intercrypto_SendToOtherBlockchain(string _coinSymbol, string _toAddress) isOwner external payable {
        uint transactionID = interCrypto.sendToOtherBlockchain.value(this.balance)(_coinSymbol, _toAddress);
        WithdrawalInterCrypto(transactionID);
    }


    function intercrypto_Recover() isOwner public {
        interCrypto.recover();
    }

    function kill() isOwner external {
        selfdestruct(owner);
    }
}
