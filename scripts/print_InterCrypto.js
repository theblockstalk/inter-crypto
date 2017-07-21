var InterCrypto = artifacts.require("./InterCrypto.sol");
var fs = require('fs');
var helpers = require('./helpers.js')

module.exports = function(callback) {
  var ethereumNetworkVersion = parseInt(web3.version.network);
  helpers.getLastLiveContract(ethereumNetworkVersion, function(lastContractAddress) {
    console.log('lastContractAddress: ' + lastContractAddress);
    var icObj = InterCrypto.at(lastContractAddress);
    fs.writeFile('./logs/InterCrypto.txt', JSON.stringify(icObj, null, '\t'), function(err) {});
  })
}
