pragma solidity ^0.4.4;

/*import "github.com/oraclize/ethereum-api/oraclizeAPI.sol"; // ORACALIZE // only works with online browser solidity*/
import './oraclizeAPI_0.4.sol'; // ORACALIZE

/// @title Inter-crypto currency converter
/// @author Jack Tanner - <jnt16@ic.ac.uk>
contract InterCrypto is usingOraclize { // ORACALIZE
/*contract InterCrypto {*/
	// _______________VARIABLES_______________
	address public owner;

  struct Transaction {
    string coinSymbol;
    address returnAddress;
    string toAddress;
		uint amount;
		address depositAddress;
    string reasonForAbort;
  }

	// TODO: make the transactionID be a hash to provide anonimity...
  mapping (uint => Transaction) transactions;
  uint transactionCount = 0;

	mapping (bytes32 => uint) oracalizeMyId2transactionID;

	// _______________EVENTS_______________
  event TransactionMade(uint transactionID);
  event TransactionAborted(uint transactionID);

	// events for debugging purposes only
	event consoleLogStr(uint indexed ID, string what, string value);
	event consoleLogUin(uint indexed ID, string what, uint value);
	event consoleLogInt(uint indexed ID, string what, int value);
	event consoleLogAdd(uint indexed ID, string what, address value);
	event consoleLogB32(uint indexed ID, string what, bytes32 value);
	event consoleLogB01(uint indexed ID, string what, bytes1 value);
	event consoleLogByt(uint indexed ID, string what, bytes value);

	// _______________EXTERNAL FUNCTIONS_______________
	// constructor
	function InterCrypto() {
		owner = msg.sender;
	}

	// suicide function
  function kill() {
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
  function sendToOtherBlockchain(string _coinSymbol, string _toAddress) external payable {
		uint oracalizePrice = getInterCryptoPrice(); // ORACALIZE
		/*uint oracalizePrice = 0;*/

		uint transactionID = transactionCount;
		transactionCount++;

		if (msg.value > oracalizePrice) {

			transactions[transactionID] = Transaction(_coinSymbol, msg.sender, _toAddress, msg.value-oracalizePrice, msg.sender, '');

			// Create post data string like ' {"withdrawal":"LbZcDdMeP96ko85H21TQii98YFF9RgZg3D","pair":"eth_ltc","returnAddress":"558999ff2e0daefcb4fcded4c89e07fdf9ccb56c"}'
			string memory postData = createShapeShiftTransactionPost(_coinSymbol, _toAddress);
			consoleLogStr(3000, 'postData', postData);

			bytes32 myQueryId = oraclize_query("URL", "json(https://shapeshift.io/shift).deposit", postData); // ORACALIZE

			oracalizeMyId2transactionID[myQueryId] = transactionID;
			consoleLogB32(3010, 'myQueryId', myQueryId); // ORACALIZE


		}
		else {
			transactions[transactionID] = Transaction(_coinSymbol, msg.sender, _toAddress, 0, msg.sender, 'Not enough ETH was sent to cover costs');

			consoleLogStr(3050, 'error', 'not enough ETH sent');
			msg.sender.transfer(msg.value);
		}

  }

	// Callback function for oracalize
	function __callback(bytes32 myid, string result) {
		if (msg.sender != oraclize_cbAddress()) throw; // ORACALIZE

		uint transactionID = oracalizeMyId2transactionID[myid];

		if( bytes(result).length == 0 ) {
			consoleLogStr(814, 'result', 'result was EMPTY');
		}
		else {
			consoleLogStr(814, 'result', result);
			address depositAddress = parseAddr(result);
			transactions[transactionID].depositAddress = depositAddress;
			consoleLogAdd(815, 'depositAddress', transactions[transactionID].depositAddress);
			depositAddress.transfer(transactions[transactionID].amount);
			consoleLogStr(816, 'transaction sent', 'true');
		}
  }

	// Getter functions for Transaction information
	function getTransactionCoinSymbol(uint transactionID) constant external returns (string) {
    return transactions[transactionID].coinSymbol;
  }
	function getTransactionReturnAddress(uint transactionID) constant external returns (address) {
    return transactions[transactionID].returnAddress;
  }
  function getTransactionToAddress(uint transactionID) constant external returns (string) {
		return transactions[transactionID].toAddress;
	}
	function getTransactionAmount(uint transactionID) constant external returns (uint) {
		return transactions[transactionID].amount;
	}
	function getTransactionReasonForAbort(uint transactionID) constant external returns (string) {
		return transactions[transactionID].reasonForAbort;
	}

	// Getter function for number of Transactions
  function getNumberOfTransactions() constant external returns (uint) {
    return transactionCount;
  }
	// _______________PUBLIC FUNCTIONS_______________


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
