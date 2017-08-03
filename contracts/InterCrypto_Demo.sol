pragma solidity ^0.4.4;

import "./InterCryptoAPI.sol";

contract InterCrypto_Demo is usingInterCrypto {

    event Transaction(uint transactionID);

    function goodSendToOtherBlockchain() external payable{
        uint transactionID = interCrypto.sendToOtherBlockchain.value(msg.value)('ltc', 'LbZcDdMeP96ko85H21TQii98YFF9RgZg3D');
        Transaction(transactionID);
    }

    function notEnoughEtherSendToOtherBlockchain() external payable{
        uint transactionID = interCrypto.sendToOtherBlockchain.value(1)('ltc', 'LbZcDdMeP96ko85H21TQii98YFF9RgZg3D');
        Transaction(transactionID);
    }

    function badSymbolEtherSendToOtherBlockchain() external payable{
        uint transactionID = interCrypto.sendToOtherBlockchain.value(msg.value)('lt c', 'LbZcDdMeP96ko85H21TQii98YFF9RgZg3D');
        Transaction(transactionID);
    }

    function badAddresslEtherSendToOtherBlockchain() external payable{
        uint transactionID = interCrypto.sendToOtherBlockchain.value(msg.value)('ltc', 'LbZcDdMeP96ko 85H21TQii98YFF9RgZg3D');
        Transaction(transactionID);
    }

    function withdrawInterCrypto() {
        interCrypto.withdraw();
    }
}

// Rinkeby interCrypto = 0x4944d0fb481983769d3d4ce4fa3b89fcad06d38e
