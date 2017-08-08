pragma solidity ^0.4.4;

contract AbstractENS {
    function owner(bytes32 node) constant returns(address);
    function resolver(bytes32 node) constant returns(address);
    function ttl(bytes32 node) constant returns(uint64);
    function setOwner(bytes32 node, address owner);
    function setSubnodeOwner(bytes32 node, bytes32 label, address owner);
    function setResolver(bytes32 node, address resolver);
    function setTTL(bytes32 node, uint64 ttl);

    // Logged when the owner of a node assigns a new owner to a subnode.
    event NewOwner(bytes32 indexed node, bytes32 indexed label, address owner);

    // Logged when the owner of a node transfers ownership to a new account.
    event Transfer(bytes32 indexed node, address owner);

    // Logged when the resolver for a node changes.
    event NewResolver(bytes32 indexed node, address resolver);

    // Logged when the TTL of a node changes
    event NewTTL(bytes32 indexed node, uint64 ttl);
}
// https://docs.ens.domains/en/latest/
// Rinkeby ENS: 0xe7410170f87102df0055eb195163a03b7f2bff4a
// .test:

// Ropsten ENS: 0x112234455c3a32fd11230c42e7bccd4a84e02010
// .eth:
// .test:

// Mainnet ENS: 0x314159265dD8dbb310642f98f50C066173C1259b
// .eth: 0x6090A6e47849629b7245Dfa1Ca21D94cd15878Ef, https://etherscan.io/ens, webapp: https://registrar.ens.domains/


contract InterCryptoI {
    // EVENTS
    event TransactionStarted(uint transactionID);
    event TransactionSentToShapeShift(uint transactionID, address depositAddress);
    event TransactionAborted(uint transactionID, string reason);

    // FUNCTIONS
    function getInterCryptoPrice() constant public returns (uint);
    function sendToOtherBlockchain(string _coinSymbol, string _toAddress) external payable returns(uint transactionID);
    // function __callback(bytes32 myid, string result);
    function recover() public;
}

contract usingInterCrypto {
    InterCryptoI public interCrypto;

    function usingInterCrypto() {
        // set intercrypto address
        // if ((address(OAR)==0)||(getCodeSize(address(OAR))==0)) oraclize_setNetwork();
        // Use ENS to get the InterCrypto address...
        interCrypto = InterCryptoI(0xd2d7f29ad51a6719a1db44f23a6975dab78cff5e);
    }
}
