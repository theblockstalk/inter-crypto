var InterCrypto = artifacts.require("./InterCrypto.sol");
// const helpers = require('../test/lib/test_helpers.js');
var fs = require('fs');

var intercryptoAddress = InterCrypto.address;
var dateStringISO = new Date().toISOString();
console.log('intercryptoAddress: ', intercryptoAddress);

// helpers.testGetInterCryptoPrice(function() {}, InterCrypto, web3.eth.accounts);

printEventsFromTransaction = function(tx) {
  // console.log(tx);
  if( typeof(tx.logs) == 'object' && typeof(tx.logs.length) != 'undefined'){
    tx.logs.forEach(function(item, index) {
      if (item.event.substr(0,10) == 'consoleLog') {
        console.log(item.event + "(" + item.args.ID + ", " + item.args.what + ", " + item.args.value + ")");
      }
    });
  }
  else {
    console.log('tx argument is not a transaction object');
  }
}

InterCrypto.at(intercryptoAddress).getInterCryptoPrice.call().then(function(res) {
  // console.log(res);
  var price = res.plus(web3.toWei(0.01, 'ether'));
  // console.log(price);
  InterCrypto.at(intercryptoAddress).sendToOtherBlockchain('ltc', 'LbZcDdMeP96ko85H21TQii98YFF9RgZg3D', {value:price, gas:500000}).then(function(tx) {
    // console.log(tx);
    printEventsFromTransaction(tx);

    var blockNumber = tx.receipt.blockNumber;

    InterCrypto.at(intercryptoAddress).consoleLogStr({ID:814}, {fromBlock: blockNumber, toBlock: 'latest'}, function(err, result) {
      console.log('consoleLogStr event found (ID: ' + result.args.ID + ', what: ' + result.args.what + ', value: ' + result.args.value + ')');
      if (err) throw err.message;
      else {
        // var txObj = InterCrypto.at(lastContractAddress);
        // fs.writeFile('./logs/' + dateStringISO +'event 814 return results.txt', JSON.stringify(result, null, '\t'), function(err) {} );
        // var txHash = result.transactionHash;
        // console.log('txHash: ', txHash);
        // var txCallback = web3.eth.getTransactionReceipt(txHash);
        // fs.writeFile('./logs/' + dateStringISO +'event 814 tx contents.txt', JSON.stringify(txCallback, null, '\t'), function(err) {} );
        // console.log(txCallback);
        // printEventsFromTransaction(txCallback);
      }
    })
  });
})

// InterCrypto.at(intercryptoAddress).sendToOtherBlockchain('ltc', 'LbZcDdMeP96ko85H21TQii98YFF9RgZg3D', {value:0}).then(function(tx) {
//   console.log(tx);
//   printEventsFromTransaction(tx);
// });
