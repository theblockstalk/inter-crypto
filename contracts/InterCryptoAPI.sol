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
// https://ropsten.etherscan.io/address/0x112234455c3a32fd11230c42e7bccd4a84e02010
// https://etherscan.io/ens (address: 0x6090A6e47849629b7245Dfa1Ca21D94cd15878Ef, webapp: https://registrar.ens.domains/, docs: https://docs.ens.domains/en/latest/)


contract InterCryptoI {
    // _______________EVENTS_______________
    event TransactionStarted(uint transactionID);
    event TransactionSentToShapeShift(uint transactionID, address depositAddress);
    event TransactionAborted(uint transactionID, string reason);

    // FUNCTIONS
    function getInterCryptoPrice() constant public returns (uint);
    function sendToOtherBlockchain(string _coinSymbol, string _toAddress) external payable returns(uint transactionID);
    function __callback(bytes32 myid, string result);
    function withdraw();
}

contract usingInterCrypto {
    InterCryptoI public interCrypto;

    function usingInterCrypto() {
        // set intercrypto address
        // if ((address(OAR)==0)||(getCodeSize(address(OAR))==0)) oraclize_setNetwork();
        // interCrypto = InterCryptoI();
    }
}
