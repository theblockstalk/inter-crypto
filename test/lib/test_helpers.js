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
const CoinSymbol = {
  BTC: 'btc',
  ETH: 'eth',
  ETC: 'etc',
  LTC: 'ltc',
}

const STATE_TEST_NAME = true;

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
  fs.appendFile('./logs/contractsCreated.log', line, function(err) {
    if (err) throw err.message;
    // console.log('Contract address was saved to logs/contractsCreated.log');
  });
}


// _______________INTERCRYPTO TEST FUNCTIONS_________________________
// ##################################################################
exports.getInfoTest = function(done, InterCrypto, accounts) {
  if (STATE_TEST_NAME) console.log('getInfoTest()');

  InterCrypto.deployed().then(function(instance) {
    instance.getInfo({from:accounts[0]}).then(function(tx) {
      // printEventsFromTransaction(tx);
      assert.equal(tx.logs[0].args.value, InterCrypto.address, "getInfo() does not emit event with its address");
      done();
    })
  })
}

exports.testGetInterCryptoPrice = function(done, InterCrypto, accounts) {
  if (STATE_TEST_NAME) console.log('testGetInterCryptoPrice()');

  InterCrypto.deployed().then(function(instance) {
    instance.getInterCryptoPrice.call().then(function(res) {
      assert.isTrue(res.isInteger(), 'Result returned from getInterCryptoPrice is not a Big Number');
      assert.isString(res.toString(), 'Result returned from getInterCryptoPrice is not a Big Number');

      // console.log('InterCryptoOracalizePrice: ' + res.toString() + ' Wei');
      done();
    })
  })
}

exports.ownerTest = function(done, InterCrypto, accounts) {
  if (STATE_TEST_NAME) console.log('ownerTest()');

  InterCrypto.deployed().then(function(instance) {
    instance.owner.call().then(function(res) {
      assert.equal(res, accounts[0], "owner variable did not return eth.accounts[0]");
      done();
    });
  })
}

exports.getNumberOfTransactionsTest = function(done, InterCrypto) {
  if (STATE_TEST_NAME) console.log('getNumberOfTransactionsTest()');

  InterCrypto.deployed().then(function(instance) {
    intercrypto = instance;
    intercrypto.getNumberOfTransactions.call().then(function(res) {
      assert.equal(res.toNumber(), 0, "There are not initially 0 transactions")
      done();
    })
  })
}

exports.testOracalizeInboundTest = function(done, InterCrypto, accounts) {
  if (STATE_TEST_NAME) console.log('testOracalizeInboundTest()');

  InterCrypto.deployed().then(function(instance) {
    var intercrypto = instance;

    callOracalizeFunctionWithValue(intercrypto.getInterCryptoPrice, done, intercrypto.testOracalizeInbound, function(tx, waterfallCallback) {
      printEventsFromTransaction(tx);

      var blockNumber = tx.receipt.blockNumber;
      console.log('blockNumber of function call: ', blockNumber);

      var oracalize_local = {
        cbAddress: tx.logs[0].args.value,
        address: tx.logs[1].args.value,
        testMyQueryId: tx.logs[2].args.value,
      }

      var ethereumNetworkVersion = parseInt(web3.version.network);
      switch(ethereumNetworkVersion) {
        case 1: // mainnet
          var oracalize_actual = {
            cbAddress: '0x0000000000000000000000000000000000000000',
            address: '0x6f28b146804dba2d6f944c03528a8fdbc673df2c',
          }
          break;
        case 2: // morden testnet
          throw "Morden testnet is not supported by Oracalize"
        case 3: // ropsten testnet
          var oracalize_actual = {
            cbAddress: '0xdc8f20170c0946accf9627b3eb1513cfd1c0499f',
            address: '0xcbf1735aad8c4b337903cd44b419efe6538aab40',
          }
          break;
        case 4: // rinkeby testnet
          var oracalize_actual = {
            cbAddress: '0x854bd635fd4e8684a326664e0698c8fefae6dd97',
            address: '0x61048b56d6e4fca6a1f6b5dac76255a413f37f4c',
          }
          break;
        case 42: // kovan testnet
          var oracalize_actual = {
            cbAddress: '0x8ebca32bd42d86ee51f762e968667e40b612b6f1',
            address: '0x0e9e2a40eef71c807d248543c9c24925ec93699c',
          }
          break;
        default:
          throw "Unknown Ethereum network version: " + ethereumNetworkVersion;
      }

      // Check that values that were logged are correct
      assert.equal(oracalize_local.cbAddress, oracalize_actual.cbAddress, "oracalize.cbAddress was incorrect");
      assert.equal(oracalize_local.address, oracalize_actual.address, "oracalize.address was incorrect");
      assert.isAbove(oracalize_local.testMyQueryId, 0, "oracalize_local.testMyQueryId does not contain a value");

      async.parallel([
        // Wait for event that reports the oracalize callback
        function(callback) {
          intercrypto.consoleLogStr({ID: 802}, {fromBlock: blockNumber, toBlock: 'latest'}, function(err, result) {
            if (err) callback(err);
            else {

              // When the event is found, extract the return value
              var dieselPriceOracalize = result.args.value;
              // console.log('consoleLogStr event found (ID: ' + result.args.ID + ', what: ' + result.args.what + ', value: ' + dieselPriceOracalize + ')');
              callback(null, dieselPriceOracalize);
            }
          });
        },
        // Fetch the diesel price from https://www.fueleconomy.gov/ws/rest/fuelprices
        function(callback) {
          https.get('https://www.fueleconomy.gov/ws/rest/fuelprices', function(res) {
            var body = '';
            res.on('data', function(chunk){
                body += chunk;
            });
            res.on('end', function(){
              var parser = new xml2js.Parser();
              xml2js.parseString(body, function(err, res) {
                var dieselPriceRequest = res['fuelPrices']['diesel'][0]

                callback(null, dieselPriceRequest);
              })
            });
          }).on('error', function(err){
              callback(err);
          });
        },

      ], function(errors, results) {
        if (errors) {
          if (errors[0]) throw errors[0].message;
          if (errors[1]) throw errors[1].message;
        }
        else {
          // Compare prices
          // console.log('dieselPriceOracalize: ', results[0], ', dieselPriceRequest: ', results[1]);
          assert.equal(results[0], results[1], 'diesel price provided by Oracalize was different from that requested directly from website')
        }
        waterfallCallback(null);
      })
    })

  })
}

exports.testOracalizeOutboundTest = function(done, InterCrypto, accounts, dateStringISO) {
  if (STATE_TEST_NAME) console.log('testOracalizeOutboundTest()');

  InterCrypto.deployed().then(function(instance) {
    var intercrypto = instance;

    callOracalizeFunctionWithValue(intercrypto.getInterCryptoPrice, done, intercrypto.testOracalizeOutbound, function(tx, waterfallCallback) {
      printEventsFromTransaction(tx);

      var blockNumber = tx.receipt.blockNumber;
      console.log('blockNumber of function call: ', blockNumber);
      var testMyQueryId = tx.logs[0].args.value;

      // Check that values that were logged are correct
      assert.isAbove(testMyQueryId, 0, "testMyQueryId does not contain a value");

      async.parallel([
        // Wait for event that reports the oracalize callback
        function(callback) {
          // console.log('wait for consoleLogStr event with ID 803');
          intercrypto.consoleLogStr({ID: 803}, {fromBlock: blockNumber, toBlock: 'latest'}, function(err, result) {
            if (err) callback(err);
            else {

              // Log the transactio for inspection
              var filename = 'logs/' + dateStringISO + ' event 803 return results.log';
              // fs.writeFile('./' + filename, JSON.stringify(result, null, '\t'), function(err) {
              //   if (err) throw err.message;
                // console.log('Event 803 watch results saved to ' + fileName);
              // });

              // When the event is found, extract the return value
              // console.log('result.args.value: ', result.args.value);
              // console.log('typeof(result.args.value): ', typeof(result.args.value));
              var latestBlockNumberOracle = parseInt(result.args.value);
              console.log('consoleLogStr event found (ID: ' + result.args.ID + ', what: ' + result.args.what + ', value: ' + latestBlockNumberOracle + ')');
              callback(null, latestBlockNumberOracle);
            }
          });
        },
        // Fetch the block number from https://ropsten.infura.io/
        function(callback) {
          // console.log('request information from API');
          var post_data = '{"jsonrpc": "2.0", "id": 1, "method": "eth_blockNumber", "params": []}';
          var post_options = {
            host: 'ropsten.infura.io',
            port: '443',
            path: '/',
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            }
          }

          var post_req = https.request(post_options, function(res) {
            res.setEncoding('utf8');

            res.on('data', function (chunk) {
                // console.log('Response: ' + chunk);
                var resObj = JSON.parse(chunk);
                // console.log('resObj.result: ', resObj.result);
                // console.log('typeof(resObj.result): ', typeof(resObj.result));

                var latestBlockNumberAPI = parseInt(resObj.result);
                callback(null, latestBlockNumberAPI)
            });
          });

          post_req.write(post_data);
          post_req.end();
        },

      ], function(errors, results) {
        if (errors) {
          if (errors[0]) throw errors[0].message;
          if (errors[1]) throw errors[1].message;
        }
        else {
          // Compare blockNumber
          // console.log('latestBlockNumber (oracalize): ' + results[0]);
          // console.log('latestBlockNumber (infura.io API): ' + results[1]);

          const BLOCK_TOLLERANCE = 10;
          assert.approximately(results[0], results[1], BLOCK_TOLLERANCE, 'Oracalize blockNumber is more than ' + BLOCK_TOLLERANCE + ' blocks difference from infura.io API');
        }
        waterfallCallback(null);
      })
    })
  })
}

exports.sendToOtherBlockchainTest = function(done, InterCrypto, accounts) {
  if (STATE_TEST_NAME) console.log('sendToOtherBlockchainTest()');

  InterCrypto.deployed().then(function(instance) {
    var intercrypto = instance;

    var local_symbol = CoinSymbol.LTC;
    var local_toAddress = 'LbZcDdMeP96ko85H21TQii98YFF9RgZg3D';

    callOracalizeFunctionWithValue(intercrypto.getInterCryptoPrice, done, intercrypto.sendToOtherBlockchain, function(tx, waterfallCallback) {
      printEventsFromTransaction(tx);

      var blockNumber = tx.receipt.blockNumber;
      console.log('blockNumber of function call: ', blockNumber);
      var testMyQueryId = tx.logs[0].args.value;
      // Check that values that were logged are correct
      assert.isAbove(testMyQueryId, 0, "testMyQueryId does not contain a value");

      async.parallel([
        // Wait for event that reports the oracalize callback
        function(callback) {
          // console.log('wait for consoleLogStr event with ID 803');
          intercrypto.consoleLogStr({ID: 814}, {fromBlock: blockNumber, toBlock: 'latest'}, function(err, result) {
            if (err) callback(err);
            else {
              var transactionID = parseInt(result.args.value);
              console.log('consoleLogStr event found (ID: ' + result.args.ID + ', what: ' + result.args.what + ', value: ' + transactionID + ')');
              callback(null, transactionID);
            }
          });
        },
        // Fetch the block number from https://ropsten.infura.io/
        function(callback) {
          // console.log('request information from API');
          var pair = 'eth_' + local_symbol;
          var post_data = '{"withdrawal": "' + local_toAddress + '", "pair": "' + pair + '", "returnAddress": "' + accounts[0] + '"}'
          console.log('post_data: ', post_data);
          var post_options = {
            host: 'shapeshift.io',
            port: '443',
            path: '/shift',
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            }
          }
          console.log('post_options: ', post_options);

          var post_req = https.request(post_options, function(res) {
            res.setEncoding('utf8');

            res.on('data', function (chunk) {
                // console.log('Response: ' + chunk);
                var resObj = JSON.parse(chunk);
                // console.log('resObj.result: ', resObj.result);
                // console.log('typeof(resObj.result): ', typeof(resObj.result));

                var latestBlockNumberAPI = parseInt(resObj.result);
                callback(null, latestBlockNumberAPI)
            });
          });

          post_req.write(post_data);
          post_req.end();
        },

      ], function(errors, results) {
        if (errors) {
          if (errors[0]) throw errors[0].message;
          if (errors[1]) throw errors[1].message;
        }
        else {
          // Compare blockNumber
          // console.log('latestBlockNumber (oracalize): ' + results[0]);
          // console.log('latestBlockNumber (infura.io API): ' + results[1]);

          const BLOCK_TOLLERANCE = 10;
          assert.approximately(results[0], results[1], BLOCK_TOLLERANCE, 'Oracalize blockNumber is more than ' + BLOCK_TOLLERANCE + ' blocks difference from infura.io API');
        }
        waterfallCallback(null);
      })

    })
/*
    intercrypto.sendToOtherBlockchain(local_symbol, local_toAddress, {from:accounts[0]}).then(function(tx) {
      printEventsFromTransaction(tx);

      async.parallel([
        function(callback) {
          intercrypto.getNumberOfTransactions.call().then(function(res) {
            callback(null, res);
          }).catch(function(err) {
            callback(err);
          });
        },
        function(callback) {
          intercrypto.getTransactionStatus.call(0).then(function(res) { callback(null, res); });
        },
        function(callback) {
          intercrypto.getTransactionCoinSymbol.call(0).then(function(res) { callback(null, res); });
        },
        function(callback) {
          intercrypto.getTransactionReturnAddress.call(0).then(function(res) { callback(null, res); });
        },
        function(callback) {
          intercrypto.getTransactionToAddress.call(0).then(function(res) { callback(null, res); });
        },
        function(callback) {
          intercrypto.getTransactionShapeShiftTransactionID.call(0).then(function(res) { callback(null, res); });
        },
        function(callback) {
          intercrypto.getTransactionReasonForAbort.call(0).then(function(res) { callback(null, res); });
        },
      ], function(err, results) {
        assert.equal(results[0].toNumber(), 1, "There is not 1 transaction");
        assert.equal(results[1].toNumber(), Status.created, "Initial Transaction status is not created");
        assert.equal(results[2], local_symbol, "coinSymbol is not 'btc'");
        assert.equal(results[3], accounts[0], "Return address is not eth.accounts[0]");
        assert.equal(results[4], local_toAddress, "To address is not " + local_toAddress);
        assert.equal(results[5], '', "ShapeShiftTransactionID is incorrect");
        assert.equal(results[6], '', "ReasonForAbort is incorrect");

        done();
      });

    });
    */
  })
}

exports.killTest = function(done, InterCrypto, accounts, intercryptoAddress) {
  if (STATE_TEST_NAME) console.log('killTest()');

  InterCrypto.deployed().then(function(instance) {
    var intercrypto = instance;

    async.series([
      // Test that kill() does not execute suicide when tx.origin != owner
      function(callback) {
        var codeBefore1 = web3.eth.getCode(intercryptoAddress);
        console.log("codeBefore1.length: " + codeBefore1.length);

        intercrypto.kill({from:accounts[1]}).then(function() {
          var codeAfter1 = web3.eth.getCode(intercryptoAddress);
          console.log("codeAfter1.length: " + codeAfter1.length);
          assert.equal(codeAfter1.length, codeBefore1.length, "Code length after is not equal to code length before");
          callback();
        });
      },
      // Test that kill() does execute suicide when tx.origin == owner
      function(callback) {
        // const SUICIDE_CONTRACT_LENGTH = 3;

        var codeBefore2 = web3.eth.getCode(intercryptoAddress);
        console.log("codeBefore2.length: " + codeBefore2.length);
        intercrypto.kill({from:accounts[0]}).then(function() {
          var codeAfter2 = web3.eth.getCode(intercryptoAddress);
          console.log("codeAfter2.length: " + codeAfter2.length);
          assert.isAtMost(codeAfter2.length, 5, "Contract has not committed suicide");
          callback();
        });
      },
    ], function(err, results) {
      done();
    });
  });
}
