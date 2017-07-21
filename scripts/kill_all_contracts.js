var InterCrypto = artifacts.require("./InterCrypto.sol");
var async = require('async');
var helpers = require('./helpers.js')

module.exports = function(callback) {
  helpers.getDeployedContracts(function(resultsArray) {
    var resultsArrayLength = resultsArray.length;
    console.log(resultsArray[0]);
    console.log(resultsArrayLength);
    console.log(resultsArray[resultsArrayLength-1]);
  });
}
