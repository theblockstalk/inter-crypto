pragma solidity ^0.4.4;

contract OraclizeI {
    address public cbAddress;
    function query(uint _timestamp, string _datasource, string _arg) payable returns (bytes32 _id);
    function query_withGasLimit(uint _timestamp, string _datasource, string _arg, uint _gaslimit) payable returns (bytes32 _id);
    function query2(uint _timestamp, string _datasource, string _arg1, string _arg2) payable returns (bytes32 _id);
    function query2_withGasLimit(uint _timestamp, string _datasource, string _arg1, string _arg2, uint _gaslimit) payable returns (bytes32 _id);
    function queryN(uint _timestamp, string _datasource, bytes _argN) payable returns (bytes32 _id);
    function queryN_withGasLimit(uint _timestamp, string _datasource, bytes _argN, uint _gaslimit) payable returns (bytes32 _id);
    function getPrice(string _datasource) returns (uint _dsprice);
    function getPrice(string _datasource, uint gaslimit) returns (uint _dsprice);
    function useCoupon(string _coupon);
    function setProofType(byte _proofType);
    function setConfig(bytes32 _config);
    function setCustomGasPrice(uint _gasPrice);
    function randomDS_getSessionPubKeyHash() returns(bytes32);
}

contract OraclizeAddrResolverI {
    function getAddress() returns (address _addr);
}

// this is a reduced and optimize version of the usingOracalize contract in https://github.com/oraclize/ethereum-api/blob/master/oraclizeAPI_0.4.sol
contract myUsingOracalize {
    OraclizeAddrResolverI OAR;

    OraclizeI oraclize;

    function myUsingOracalize() {
        if ((address(OAR)==0)||(getCodeSize(address(OAR))==0)) oraclize_setNetwork();
        oraclize = OraclizeI(OAR.getAddress());
    }

    function update_oracalize() external {
        oraclize = OraclizeI(OAR.getAddress());
    }

    function oraclize_setNetwork() internal returns(bool) {
        if (getCodeSize(0x1d3B2638a7cC9f2CB3D298A3DA7a90B67E5506ed)>0){ //mainnet
            OAR = OraclizeAddrResolverI(0x1d3B2638a7cC9f2CB3D298A3DA7a90B67E5506ed);
            return true;
        }
        if (getCodeSize(0xc03A2615D5efaf5F49F60B7BB6583eaec212fdf1)>0){ //ropsten testnet
            OAR = OraclizeAddrResolverI(0xc03A2615D5efaf5F49F60B7BB6583eaec212fdf1);
            return true;
        }
        if (getCodeSize(0xB7A07BcF2Ba2f2703b24C0691b5278999C59AC7e)>0){ //kovan testnet
            OAR = OraclizeAddrResolverI(0xB7A07BcF2Ba2f2703b24C0691b5278999C59AC7e);
            return true;
        }
        if (getCodeSize(0x146500cfd35B22E4A392Fe0aDc06De1a1368Ed48)>0){ //rinkeby testnet
            OAR = OraclizeAddrResolverI(0x146500cfd35B22E4A392Fe0aDc06De1a1368Ed48);
            return true;
        }
        if (getCodeSize(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475)>0){ //ethereum-bridge
            OAR = OraclizeAddrResolverI(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475);
            return true;
        }
        if (getCodeSize(0x20e12A1F859B3FeaE5Fb2A0A32C18F5a65555bBF)>0){ //ether.camp ide
            OAR = OraclizeAddrResolverI(0x20e12A1F859B3FeaE5Fb2A0A32C18F5a65555bBF);
            return true;
        }
        if (getCodeSize(0x51efaF4c8B3C9AfBD5aB9F4bbC82784Ab6ef8fAA)>0){ //browser-solidity
            OAR = OraclizeAddrResolverI(0x51efaF4c8B3C9AfBD5aB9F4bbC82784Ab6ef8fAA);
            return true;
        }
        return false;
    }

    function oraclize_query(string datasource, string arg1, string arg2) internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        return oraclize.query2.value(price)(0, datasource, arg1, arg2);
    }

    function getCodeSize(address _addr) constant internal returns(uint _size) {
        assembly {
            _size := extcodesize(_addr)
        }
        return _size;
    }

    function parseAddr(string _a) internal returns (address){
        bytes memory tmp = bytes(_a);
        uint160 iaddr = 0;
        uint160 b1;
        uint160 b2;
        for (uint i=2; i<2+2*20; i+=2){
            iaddr *= 256;
            b1 = uint160(tmp[i]);
            b2 = uint160(tmp[i+1]);
            if ((b1 >= 97)&&(b1 <= 102)) b1 -= 87;
            else if ((b1 >= 65)&&(b1 <= 70)) b1 -= 55;
            else if ((b1 >= 48)&&(b1 <= 57)) b1 -= 48;
            if ((b2 >= 97)&&(b2 <= 102)) b2 -= 87;
            else if ((b2 >= 65)&&(b2 <= 70)) b2 -= 55;
            else if ((b2 >= 48)&&(b2 <= 57)) b2 -= 48;
            iaddr += (b1*16+b2);
        }
        return address(iaddr);
    }
}

/// @title Inter-crypto currency converter
/// @author Jack Tanner - <jnt16@ic.ac.uk>
// TODO: spicfy variables as memory or storage, and functions as prive, internal, public or external to optimize
contract InterCrypto is myUsingOracalize {
    // _______________VARIABLES_______________
    address owner;

    struct Transaction {
        address returnAddress;
        uint amount;
    }

    mapping (uint => Transaction) transactions;
    uint transactionCount = 0;
    mapping (bytes32 => uint) oracalizeMyId2transactionID;
    mapping (address => uint) pendingWithdrawals;

    // _______________EVENTS_______________
    event TransactionStarted(uint transactionID);
    event TransactionSentToShapeShift(uint transactionID, address depositAddress);
    event TransactionAborted(uint transactionID, string reason);

    // events for debugging purposes only
    // event consoleLogStr(uint indexed ID, string what, string value);
    // event consoleLogUin(uint indexed ID, string what, uint value);
    // event consoleLogInt(uint indexed ID, string what, int value);
    // event consoleLogAdd(uint indexed ID, string what, address value);
    // event consoleLogB32(uint indexed ID, string what, bytes32 value);
    // event consoleLogB01(uint indexed ID, string what, bytes1 value);
    // event consoleLogByt(uint indexed ID, string what, bytes value);

    // _______________EXTERNAL FUNCTIONS_______________
    // constructor
    function InterCrypto() {
        owner = msg.sender;
    }

    // suicide function
    function kill() external {
        if (msg.sender == owner)
        selfdestruct(owner);
    }

    // Default function which will accept Ether
    function () payable {}

    // Return the price of using Oracalize
    function getInterCryptoPrice() constant public returns (uint) {
        return oraclize.getPrice('URL');
    }

    // Request for a ShapeShift transaction to be made
    function sendToOtherBlockchain(string _coinSymbol, string _toAddress) external payable returns(uint transactionID) {
        // Example arguments:
        // "ltc", "LbZcDdMeP96ko85H21TQii98YFF9RgZg3D"   Litecoin
        // "btc", "1L8oRijgmkfcZDYA21b73b6DewLtyYs87s"   Bitcoin
        // "dash", "Xoopows17idkTwNrMZuySXBwQDorsezQAx"  Dash
        // "zec", "t1N7tf1xRxz5cBK51JADijLDWS592FPJtya"  ZCash
        // "doge" "DMAFvwTH2upni7eTau8au6Rktgm2bUkMei"   Dogecoin
        // See https://info.shapeshift.io/about
        // Test symbol pairs using POST transaction with ShapeShift API before using it with InterCrypto

        uint oracalizePrice = getInterCryptoPrice(); // ORACALIZE

        transactionID = transactionCount; // CAN THESE TWO LINES BE DONE IN ONE LINE MORE EFFICIENTLY??? transactionID = transactionCount++;
        transactionCount++;

        if (msg.value > oracalizePrice) {
            transactions[transactionID] = Transaction(msg.sender, msg.value-oracalizePrice);

            // Create post data string like ' {"withdrawal":"LbZcDdMeP96ko85H21TQii98YFF9RgZg3D","pair":"eth_ltc","returnAddress":"558999ff2e0daefcb4fcded4c89e07fdf9ccb56c"}'
            string memory postData = createShapeShiftTransactionPost(_coinSymbol, _toAddress);

            // TODO: send custom gasLimit for retrn transaction equal to the exact cost of __callback
            bytes32 myQueryId = oraclize_query("URL", "json(https://shapeshift.io/shift).deposit", postData); // ORACALIZE
            if (myQueryId == 0) {
                TransactionAborted(transactionID, "unexpectedly high Oracalize price when calling oracalize_query");
                pendingWithdrawals[msg.sender] += msg.value-oracalizePrice;
                transactions[transactionID].amount = 0;
                return;
            }
            oracalizeMyId2transactionID[myQueryId] = transactionID;
            TransactionStarted(transactionID);
        }
        else {
            TransactionAborted(transactionID, "Not enough ETH sent to cover Oracalize fee");
            pendingWithdrawals[msg.sender] += msg.value;
            // msg.sender.transfer(msg.value); // IS THIS SAFE??? PERHAPS SHOULD USE SAFE WITHDRAWAL
        }
    }

    // Callback function for oracalize
    function __callback(bytes32 myid, string result) {
        if (msg.sender != oraclize.cbAddress()) revert(); // ORACALIZE

        uint transactionID = oracalizeMyId2transactionID[myid];

        if( bytes(result).length == 0 ) {
            TransactionAborted(transactionID, "Oracalize return value was invalid");
            pendingWithdrawals[transactions[transactionID].returnAddress] += transactions[transactionID].amount;
            transactions[transactionID].amount = 0;
            // transactions[transactionID].returnAddress.transfer(transactions[transactionID].amount); // IS THIS SAFE??? PERHAPS SHOULD USE SAFE WITHDRAWAL
        }
        else {
            address depositAddress = parseAddr(result);
            assert(depositAddress != msg.sender); // prevent potential DAO hack that can potentially be done by oracalize
            uint sendAmount = transactions[transactionID].amount;
            transactions[transactionID].amount = 0;
            if (depositAddress.send(sendAmount))
                TransactionSentToShapeShift(transactionID, depositAddress);
            else {
                TransactionAborted(transactionID, "transaction to address returned by Oracalize failed");
                pendingWithdrawals[transactions[transactionID].returnAddress] += sendAmount;
                // transactions[transactionID].returnAddress.transfer(transactions[transactionID].amount); // IS THIS SAFE??? PERHAPS SHOULD USE SAFE WITHDRAWAL
            }
            //TODO: optional callback to original sender to let them know transaction is finished???
        }
    }

    //TODO: function to cancel specif transaction 1 transaction. Uses safe withdrawal... ???
    // _______________PUBLIC FUNCTIONS_______________
    function recover() public {
        uint amount = pendingWithdrawals[msg.sender];
        pendingWithdrawals[msg.sender] = 0;
        msg.sender.transfer(amount);
    }

    // _______________INTERNAL FUNCTIONS_______________
    // Authored by https://github.com/axic
    function nibbleToChar(uint nibble) internal returns (uint ret) {
        if (nibble > 9)
        return nibble + 87; // nibble + 'a'- 10
        else
        return nibble + 48; // '0'
    }

    // Authored by https://github.com/axic
    // basically this is an int to hexstring function, but limited to 160 bits
    // FIXME: could be much simpler if we have a simple way of converting bytes32 to bytes or string
    function addressToBytes(address _address) internal returns (bytes) {
        uint160 tmp = uint160(_address);

        // 40 bytes of space, but actually uses 64 bytes
        string memory holder = "                                        ";
        bytes memory ret = bytes(holder);

        // NOTE: this is written in an expensive way, as out-of-order array access
        //       is not supported yet, e.g. we cannot go in reverse easily
        //       (or maybe it is a bug: https://github.com/ethereum/solidity/issues/212)
        uint j = 0;
        for (uint i = 0; i < 20; i++) {
            uint _tmp = tmp / (2 ** (8*(19-i))); // shr(tmp, 8*(19-i))
            uint nb1 = (_tmp / 0x10) & 0x0f;     // shr(tmp, 8) & 0x0f
            uint nb2 = _tmp & 0x0f;
            ret[j++] = byte(nibbleToChar(nb1));
            ret[j++] = byte(nibbleToChar(nb2));
        }

        return ret;
    }

    function concatBytes(bytes b1, bytes b2, bytes b3, bytes b4, bytes b5, bytes b6, bytes b7) internal returns (bytes bFinal) {
        bFinal = new bytes(b1.length + b2.length + b3.length + b4.length + b5.length + b6.length + b7.length);

        uint i = 0;
        uint j;
        for (j = 0; j < b1.length; j++) bFinal[i++] = b1[j];
        for (j = 0; j < b2.length; j++) bFinal[i++] = b2[j];
        for (j = 0; j < b3.length; j++) bFinal[i++] = b3[j];
        for (j = 0; j < b4.length; j++) bFinal[i++] = b4[j];
        for (j = 0; j < b5.length; j++) bFinal[i++] = b5[j];
        for (j = 0; j < b6.length; j++) bFinal[i++] = b6[j];
        for (j = 0; j < b7.length; j++) bFinal[i++] = b7[j];
    }

    function createShapeShiftTransactionPost(string _coinSymbol, string _toAddress) internal returns (string sFinal) {
        string memory s1 = ' {"withdrawal":"';
        string memory s3 = '","pair":"eth_';
        string memory s5 = '","returnAddress":"';
        string memory s7 = '"}';

        bytes memory bFinal = concatBytes(bytes(s1), bytes(_toAddress), bytes(s3), bytes(_coinSymbol), bytes(s5), bytes(addressToBytes(msg.sender)), bytes(s7));

        sFinal = string(bFinal);
    }

    // _______________PRIVATE FUNCTIONS_______________

}
