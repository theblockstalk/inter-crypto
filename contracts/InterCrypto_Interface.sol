pragma solidity ^0.4.15;

import "https://github.com/OpenZeppelin/zeppelin-solidity/contracts/ownership/Ownable.sol";

interface AbstractENS {
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
// namehash('test') = "0x04f740db81dc36c853ab4205bddd785f46e79ccedca351fc6dfcbd8cc9a33dd6"
// namehash('eth') = "0x93cdeb708b7545dc668eb9280176169d1c33cfd8ed6f04690a0bcc88a93fc4ae"
// namehash('intercrypto.test') = "0x9a8369851a1b569f68940f87a1ee6b276ee3d4cb037cf4d073598669c1ade6a8"
// namehash('jackdomain.test') = "0xf2cf3eab504436e1b5a541dd9fbc5ac8547b773748bbf2bb81b350ee580702ca"
// namehash('intercrypto.jackdomain.test') = "0xbe93c9e419d658afd89a8650dd90e37e763e75da1e663b9d57494aedf27f3eaa"
// namehash('wallet.intercrypto.jackdomain.test') = "0x41cb24b2da4620fd1f7ea359a349bbba555ca4c8274a3fca4b53f0fd5d519a4e"

// Rinkeby ENS: 0xe7410170f87102df0055eb195163a03b7f2bff4a
// .test: 0x21397c1a1f4acd9132fe36df011610564b87e24b

// Ropsten ENS: 0x112234455c3a32fd11230c42e7bccd4a84e02010
// .eth: 0xc19fd9004b5c9789391679de6d766b981db94610
// .test: 0x21397c1a1f4acd9132fe36df011610564b87e24b

// Mainnet ENS: 0x314159265dD8dbb310642f98f50C066173C1259b
// .eth: 0x6090A6e47849629b7245Dfa1Ca21D94cd15878Ef, https://etherscan.io/ens, webapp: https://registrar.ens.domains/

interface InterCrypto_Interface {
    // EVENTS
    event TransactionStarted(uint indexed transactionID);
    event TransactionSentToShapeShift(uint indexed transactionID, address indexed returnAddress, address indexed depositAddress, uint amount);
    event TransactionAborted(uint indexed transactionID, string reason);
    event Recovered(address indexed recoveredTo, uint amount);

    // FUNCTIONS
    function getInterCryptoPrice() constant public returns (uint);
    function sendToOtherBlockchain(string _coinSymbol, string _toAddress) external payable returns (uint transactionID);
    function sendToOtherBlockchain(string _coinSymbol, string _toAddress, address _returnAddress) external payable returns(uint transactionID);
    function recover() external;
    function recoverable(address myAddress) constant public returns (uint);
    function cancelTransaction(uint transactionID) external;
}

contract usingInterCrypto is Ownable {
    AbstractENS public abstractENS;

    InterCrypto_Interface public interCrypto;
    bytes32 public ENSresolverNode;

    function usingInterCrypto() public {
        setNetwork();
        updateInterCrypto();

    }

    function setNetwork() internal returns(bool) {
        if (getCodeSize(0x314159265dD8dbb310642f98f50C066173C1259b)>0){ //mainnet
            abstractENS = AbstractENS(0x314159265dD8dbb310642f98f50C066173C1259b);
            ENSresolverNode = 0x921a56636fce44f7cbd33eed763c940f580add9ffb4da7007f8ff6e99804a7c8; // intercrypto.jacksplace.eth
        }
        else if (getCodeSize(0xe7410170f87102df0055eb195163a03b7f2bff4a)>0){ //rinkeby
            abstractENS = AbstractENS(0xe7410170f87102df0055eb195163a03b7f2bff4a);
            ENSresolverNode = 0xbe93c9e419d658afd89a8650dd90e37e763e75da1e663b9d57494aedf27f3eaa; // intercrypto.jackdomain.test
        }
        else if (getCodeSize(0x112234455c3a32fd11230c42e7bccd4a84e02010)>0){ //ropsten
            abstractENS = AbstractENS(0x112234455c3a32fd11230c42e7bccd4a84e02010);
            ENSresolverNode = 0xbe93c9e419d658afd89a8650dd90e37e763e75da1e663b9d57494aedf27f3eaa; // intercrypto.jackdomain.test
        }
        else {
            revert();
        }
    }

    function updateInterCrypto() public {
        interCrypto = InterCrypto_Interface(abstractENS.resolver(ENSresolverNode));
    }

    function updateENSnode(bytes32 newNodeName) onlyOwner public {
        ENSresolverNode = newNodeName;
    }

    function getCodeSize(address _addr) constant internal returns(uint _size) {
        assembly {
            _size := extcodesize(_addr)
        }
        return _size;
    }
}
