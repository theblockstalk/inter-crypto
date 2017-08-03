pragma solidity ^0.4.4;

contract InterCryptoI {
    // _______________EVENTS_______________
    event TransactionStarted(uint transactionID);
    event TransactionSentToShapeShift(uint transactionID, address depositAddress);
    event TransactionAborted(uint transactionID, string reason);

    // FUNCTIONS
    function getInterCryptoPrice() constant public returns (uint);
    function sendToOtherBlockchain(string _coinSymbol, string _toAddress) external payable returns(uint transactionID);
    function __callback(bytes32 myid, string result);
}

contract usingInterCrypto {
    InterCryptoI interCrypto;
}
