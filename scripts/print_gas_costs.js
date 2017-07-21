var InterCrypto = artifacts.require("./InterCrypto.sol");
// var async = require('async');
var helpers = require('./helpers.js')
const solc = require('solc')
var fs = require('fs');

module.exports = function(callback) {
  var ethereumNetworkVersion = parseInt(web3.version.network);

  var transactionObject = {
    from: web3.eth.accounts[0],
    to: web3.eth.accounts[1],
    value: 1,
  }
  var gas_cost = web3.eth.estimateGas(transactionObject);
  console.log('ether transaction: ', gas_cost);

  transactionObject = {
    from: web3.eth.accounts[0],
    to: web3.eth.accounts[1],
    value: 1,
    data: '0x01',
  }
  gas_cost = web3.eth.estimateGas(transactionObject);
  console.log('ether transaction with 4xbytes: ', gas_cost);

  transactionObject = {
    from: web3.eth.accounts[0],
    to: web3.eth.accounts[1],
    value: 1,
    data: '0x00000000000000000001',
  }
  gas_cost = web3.eth.estimateGas(transactionObject);
  console.log('ether transaction with 40xbytes: ', gas_cost);

  transactionObject = {
    from: web3.eth.accounts[0],
    value: 1,
  }
  gas_cost = web3.eth.estimateGas(transactionObject);
  console.log('ether transaction with no to address: ', gas_cost);

  transactionObject = {
    to: web3.eth.accounts[1],
    value: 1,
  }
  gas_cost = web3.eth.estimateGas(transactionObject);
  console.log('ether transaction with no from address: ', gas_cost);

  transactionObject = {
    value: 1,
  }
  gas_cost = web3.eth.estimateGas(transactionObject);
  console.log('ether transaction with no from or to address: ', gas_cost);

  transactionObject = {
    from: web3.eth.accounts[0],
    to: web3.eth.accounts[1],
  }
  gas_cost = web3.eth.estimateGas(transactionObject);
  console.log('ether transaction with no value: ', gas_cost);

  // helpers.getTransactionsByAccount(web3.eth.accounts[0], web3)

  helpers.getLastLiveContract(ethereumNetworkVersion, function(lastContractAddress) {
    console.log('lastContractAddress: ' + lastContractAddress);
    var bytecode1 = web3.eth.getCode(lastContractAddress);

    var icObj = InterCrypto.at(lastContractAddress);
    // var cost = icObj.getInfo().estimateGas();
    // console.log(cost);
    // var newdata = icObj.new.getData();
    // var abiByteString = web3.eth.abi.encodeFunctionSignature('getInfo()');
    // console.log('abiByteString: ', abiByteString);

    var InterCryptoSource = fs.readFileSync('./contracts/InterCrypto.sol', 'utf8');
    var OracalizAPIeSource = fs.readFileSync('./contracts/oraclizeAPI_0.4.sol', 'utf8');
    var inputSources = {
      'oraclizeAPI_0.4.sol': OracalizAPIeSource,
      'InterCrypto.sol': InterCryptoSource,
    }
    let compiledContract = solc.compile({sources: inputSources}, 1);
    for (var contractName in compiledContract.contracts) {
        // code and ABI that are needed by web3
        // console.log(contractName + ' bytecode length: ' + compiledContract.contracts[contractName].bytecode.length)
        // console.log(contractName + ': ' + JSON.parse(compiledContract.contracts[contractName].interface.length));
    }
    var abi = compiledContract.contracts['InterCrypto.sol:InterCrypto'].interface;
    var bytecode2 = '0x' + compiledContract.contracts['InterCrypto.sol:InterCrypto'].bytecode;
    console.log('bytecode1.length: ', bytecode1.length, ' gasEstimate: ', web3.eth.estimateGas({data: bytecode1}));
    console.log('bytecode2.length: ', bytecode2.length, ' gasEstimate: ', web3.eth.estimateGas({data: bytecode2}));

    // https://web3js.readthedocs.io/en/1.0/web3-eth.html#sendtransaction
    transactionObject = {
      // from: web3.eth.accounts[0],
      // to: lastContractAddress,
      // from: web3.eth.accounts[0],
      // to: web3.eth.accounts[1],
      data: '0x01',
    }
    gas_cost = web3.eth.estimateGas(transactionObject);
    console.log('InterCrypto.getInfo(): ', gas_cost);
    // fs.writeFile('./logs/InterCrypto.txt', JSON.stringify(icObj, null, '\t'), function(err) {});
  })
}
