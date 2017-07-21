var InterCrypto = artifacts.require("./InterCrypto.sol");
var async = require('async');
var fs = require('fs');
var https = require('https');

module.exports = function(callback) {
  async.series([
    function(callback) {
      var latestBlockNumber = web3.eth.blockNumber;
      callback(null, latestBlockNumber);
    },
    function(callback) {
      web3.version.getNetwork((err, netId) => {
        switch (netId) {
          case "1":
            // mainnet
            callback(null, 'mainnet.infura.io');
            break;
          case "2":
            // deprecated Morden test network.
            callback(null, 2);
            break;
          case "3":
            // Ropsten test network
            callback(null, 'ropsten.infura.io');
            break;
          default:
            callback(null, 4);
        }
      });
    },

  ], function(errors, results) {
    if (results[1] == 2 || results[1] == 4) {
      console.log('Public blockchain is not in use, block number will not be checked')
    }
    else {
      console.log('Blockchain API to use to verify block number: https://' + results[1]);
      // Compare prices
      var post_data = '{"jsonrpc": "2.0", "id": 1, "method": "eth_blockNumber", "params": []}';
      var post_options = {
        host: results[1],
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
            var latestBlockNumber = parseInt(resObj.result);

            console.log('latestBlockNumber (local): ' + results[0]);
            console.log('latestBlockNumber (infura.io): ' + latestBlockNumber)
        });
      });

      post_req.write(post_data);
      post_req.end();
    }
  })
}
