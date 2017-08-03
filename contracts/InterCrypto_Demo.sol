pragma solidity ^0.4.4;

import "./InterCryptoAPI.sol";

contract InterCrypto_Demo is usingInterCrypto {

    event Transaction(uint transactionID);
    function proxyToInterCrypto() external payable{
        uint transactionID = interCrypto.sendToOtherBlockchain.value(msg.value)('ltc', 'LbZcDdMeP96ko85H21TQii98YFF9RgZg3D');
        Transaction(transactionID);
    }
}

// Rinkeby interCrypto = 0x4944d0fb481983769d3d4ce4fa3b89fcad06d38e
