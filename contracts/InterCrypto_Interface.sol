pragma solidity ^0.4.15;

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

contract TestRegistrar {
    AbstractENS public ens;
    bytes32 public rootNode;
    mapping(bytes32=>uint) public expiryTimes;

    function register(bytes32 subnode, address owner); // creates node = namehash(rootNode, subnode) from ensutils.js. This is what can be looked up using top level ENS contrac wth owner and resolver functions
}
// https://docs.ens.domains/en/latest/
// namehash('test') = "0x04f740db81dc36c853ab4205bddd785f46e79ccedca351fc6dfcbd8cc9a33dd6"
// namehash('eth') = "0x93cdeb708b7545dc668eb9280176169d1c33cfd8ed6f04690a0bcc88a93fc4ae"
// namehash('intercrypto.test') = "0x9a8369851a1b569f68940f87a1ee6b276ee3d4cb037cf4d073598669c1ade6a8"

// Rinkeby ENS: 0xe7410170f87102df0055eb195163a03b7f2bff4a
// .test: 0x21397c1a1f4acd9132fe36df011610564b87e24b

// Ropsten ENS: 0x112234455c3a32fd11230c42e7bccd4a84e02010
// .eth:
// .test:

// Mainnet ENS: 0x314159265dD8dbb310642f98f50C066173C1259b
// .eth: 0x6090A6e47849629b7245Dfa1Ca21D94cd15878Ef, https://etherscan.io/ens, webapp: https://registrar.ens.domains/


contract InterCrypto_Interface {
    // EVENTS
    event TransactionStarted(uint transactionID);
    event TransactionSentToShapeShift(uint transactionID, address depositAddress);
    event TransactionAborted(uint transactionID, string reason);

    // FUNCTIONS
    function getInterCryptoPrice() constant public returns (uint);
    function sendToOtherBlockchain(string _coinSymbol, string _toAddress) external payable returns (uint transactionID);
    function recover() external;
    function amountRecoverable() constant public returns (uint);
    function cancelTransaction(uint transactionID) external;
}

contract usingInterCrypto {
    AbstractENS public abstractENS;

    InterCrypto_Interface public interCrypto;

    function usingInterCrypto() public {
        if ((address(abstractENS)==0)||(getCodeSize(address(abstractENS))==0)) ENS_setNetwork();
        updateInterCrypto();

    }

    function ENS_setNetwork() internal returns(bool) {
        if (getCodeSize(0x314159265dD8dbb310642f98f50C066173C1259b)>0){ //mainnet
            abstractENS = AbstractENS(0x314159265dD8dbb310642f98f50C066173C1259b);
            return true;
        }
        if (getCodeSize(0xe7410170f87102df0055eb195163a03b7f2bff4a)>0){ //rinkeby
            abstractENS = AbstractENS(0xe7410170f87102df0055eb195163a03b7f2bff4a);
            return true;
        }
        if (getCodeSize(0x112234455c3a32fd11230c42e7bccd4a84e02010)>0){ //ropsten
            abstractENS = AbstractENS(0x112234455c3a32fd11230c42e7bccd4a84e02010);
            return true;
        }
        return false;
    }

    function updateInterCrypto() public {
        interCrypto = InterCrypto_Interface(abstractENS.resolver(0x9a8369851a1b569f68940f87a1ee6b276ee3d4cb037cf4d073598669c1ade6a8));
    }

    function getCodeSize(address _addr) constant internal returns(uint _size) {
        assembly {
            _size := extcodesize(_addr)
        }
        return _size;
    }
}
