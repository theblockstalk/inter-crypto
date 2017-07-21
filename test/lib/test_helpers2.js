var async = require('async');
var fs = require('fs');
var https = require('https');
var xml2js = require('xml2js');

const Status = {
  created: 0,
  waitingForDeposit: 1,
  transactionPending: 2,
  transactionComplete: 3,
  transactionAborted: 4,
}

const STATE_TEST_NAME = false;
const DEPLOY_NEW = true;

// _______________PRIVATE FUNCTIONS_________________________
// #########################################################
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

callOracalizeFunctionWithValue = function(priceFunction, done, oracleFunction, functionCallback) {
  async.waterfall([
    function(callback) {
      priceFunction.call().then(function(InterCryptoOracalizePrice) {
        console.log('InterCryptoOracalizePrice: ' + InterCryptoOracalizePrice.toString() + ' Wei');
        callback(null, InterCryptoOracalizePrice);
      })
    },
    function(InterCryptoOracalizePrice, callback) {
      oracleFunction({value:InterCryptoOracalizePrice}).then( function(res) {
        functionCallback(res, callback);
      });
    },
  ], function(errors, results) {
    done();
  })
}
// _______________EXPORTED FUNCTIONS_________________________
// ##########################################################
exports.checkLocalBlockAgainstAPI = function(done) {
  if (STATE_TEST_NAME) console.log('checkLocalBlockAgainstAPI()');

  var ethereumNetworkVersion = parseInt(web3.version.network);

  if (ethereumNetworkVersion > 10) {
    console.log('Public blockchain is not in use, block number will not be checked');
    done();
  }
  else {
    var urlAPI;
    switch(ethereumNetworkVersion) {
      case 1:
        urlAPI = 'mainnet.infura.io';
        break;
      case 3:
        urlAPI = 'ropsten.infura.io';
        break;
      case 4:
        urlAPI = 'rinkeby.infura.io';
        break;
      default:
        throw "Unknown Ethereum network version: " + ethereumNetworkVersion;
    }

    var post_data = '{"jsonrpc": "2.0", "id": 1, "method": "eth_blockNumber", "params": []}';
    var post_options = {
      host: urlAPI,
      port: '443',
      path: '/',
      method: 'POST',
      headers: {
          'Content-Type': 'application/json',
      }
    }

    var post_req = https.request(post_options, function(res) {
      // console.log('Status: ' + res.statusCode);
      // console.log('Headers: ' + JSON.stringify(res.headers));
      res.setEncoding('utf8');

      res.on('data', function (chunk) {
          // console.log('Response: ' + chunk);
          var resObj = JSON.parse(chunk);
          var latestBlockNumberAPI = parseInt(resObj.result);
          var latestBlockNumberLocal = web3.eth.blockNumber;
          // console.log('Blockchain API to use to verify block number: https://' + urlAPI);
          // console.log('latestBlockNumber (local): ' + latestBlockNumberLocal);
          // console.log('latestBlockNumber (infura.io): ' + latestBlockNumberAPI);

          const BLOCK_TOLLERANCE = 5;
          assert.approximately(latestBlockNumberLocal, latestBlockNumberAPI, BLOCK_TOLLERANCE, 'Local blockchain node is more than ' + BLOCK_TOLLERANCE + ' blocks difference from api');

          done();
      });
    });

    post_req.write(post_data);
    post_req.end();
  }
}

exports.printConractToLog = function(intercryptoAddress, dateStringISO) {
  var ethereumNetworkVersion = parseInt(web3.version.network);
  console.log("InterCrypto.address: " + intercryptoAddress);
  console.log('Datestamp: ' + dateStringISO);

  // Save address to file so that they can be killed later
  var line = '\n' + dateStringISO + ', ' + ethereumNetworkVersion + ', ' + intercryptoAddress;
  fs.appendFile('../logs/contractsCreated.log', line, function(err) {
    if (err) throw err.message;
    // console.log('Contract address was saved to logs/contractsCreated.log');
  });
}


// _______________INTERCRYPTO TEST FUNCTIONS_________________________
// ##################################################################
exports.deployContracts = function(done, InterCrypto, interCryptoInstance, intercryptoAddress) {
  async.waterfall([
    function(callback) {
      if (DEPLOY_NEW) {
        console.log("Deploying new contract");
        InterCrypto.new().then(function(instance) {
          interCryptoInstance = instance;
          callback(null, interCryptoInstance)
        }).catch(function(err) {
          callback(err);
        });
      }
      else {
        console.log("Using last deployed contract");
        InterCrypto.deployed().then(function(instance) {
          interCryptoInstance = instance;
          callback(null, interCryptoInstance)
        }).catch(function(err) {
          callback(err);
        });
      }
    },
    function(args1, callback) {
      intercryptoAddress = args1.address;

      var dateStringISO = new Date().toISOString();
      exports.printConractToLog(intercryptoAddress, dateStringISO);
      callback(null);
    }
  ], function(errors, results) {
    if (errors) throw errors;
    done();
  });
}
