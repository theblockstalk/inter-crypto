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

interface InterCrypto_Interface {
    // EVENTS
    event ConversionStarted(uint indexed conversionID);
    event ConversionSentToShapeShift(uint indexed conversionID, address indexed returnAddress, address indexed depositAddress, uint amount);
    event ConversionAborted(uint indexed conversionID, string reason);
    event Recovered(address indexed recoveredTo, uint amount);

    // FUNCTIONS
    function getInterCryptoPrice() constant public returns (uint);
    function convert1(string _coinSymbol, string _toAddress) external payable returns (uint conversionID);
    function convert2(string _coinSymbol, string _toAddress, address _returnAddress) external payable returns(uint conversionID);
    function recover() external;
    function recoverable(address myAddress) constant public returns (uint);
    function cancelConversion(uint conversionID) external;
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

    function updateInterCrypto() onlyOwner public {
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

    function intercrypto_convert(uint amount, string _coinSymbol, string _toAddress) internal returns (uint conversionID) {
        return interCrypto.convert1.value(amount)(_coinSymbol, _toAddress);
    }

    function intercrypto_convert(uint amount, string _coinSymbol, string _toAddress, address _returnAddress) internal returns(uint conversionID) {
        return interCrypto.convert2.value(amount)(_coinSymbol, _toAddress, _returnAddress);
    }

    // If you want to allow public use of functions getInterCryptoPrice(), recover(), recoverable() or cancelConversion() then please copy the following as necessary
    // into your smart contract. They are not included by default for security reasons.

    // function intercrypto_getInterCryptoPrice() constant public returns (uint) {
    //     return interCrypto.getInterCryptoPrice();
    // }
    // function intercrypto_recover() onlyOwner public {
    //     interCrypto.recover();
    // }
    // function intercrypto_recoverable() constant public returns (uint) {
    //     return interCrypto.recoverable(this);
    // }
    // function intercrypto_cancelConversion(uint conversionID) onlyOwner external {
    //     interCrypto.cancelConversion(conversionID);
    // }
}
