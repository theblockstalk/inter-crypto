var fs = require('fs');
var readline = require('readline');

exports.getDeployedContracts = function(callback) {
  var resultsArray = [];

  var lineReader = readline.createInterface({
    input: fs.createReadStream('./logs/contractsCreated.log')
  });

  lineReader.on('line', function (line) {
    var stringPieces = line.split(',');
    var timestamp, networkId, contract, status;
    if (stringPieces.length > 1) {
      switch (stringPieces.length) {
        case 2:
          timestamp = stringPieces[0];
          networkId = null;
          contract = stringPieces[1].replace(/\s+/g, '');
          status = 'alive';
          break;
        case 3:
          timestamp = stringPieces[0];
          networkId = parseInt(stringPieces[1]);
          contract = stringPieces[2].replace(/\s+/g, '');
          status = 'alive';
          break;
        case 4:
          timestamp = stringPieces[0];
          networkId = parseInt(stringPieces[1]);
          contract = stringPieces[2].replace(/\s+/g, '');
          status = stringPieces[3];
          break;
      }

      var contractInfo = {
        'timestamp': timestamp,
        'networkId': networkId,
        'contract': contract,
        'status': status,
      }

      resultsArray.push(contractInfo);
    }
  });
  lineReader.on('close', function() {
    callback(resultsArray);
  })
}

exports.getLastLiveContract = function(ethereumNetworkVersion, callback) {

  exports.getDeployedContracts(function(resultsArray) {
    var resultsArrayLength = resultsArray.length;
    var lastContractAddress = null;
    for (var i = resultsArrayLength-1; i >= 0; i--) {
      if (resultsArray[i].networkId == ethereumNetworkVersion && resultsArray[i].status == 'alive') {
        lastContractAddress = resultsArray[i].contract;
        break;
      }
    }

    if (lastContractAddress == null) {
      throw "No live contract was found on this network"
    }
    else {
      callback(lastContractAddress);
    }

  });
}

exports.getTransactionsByAccount = function(myaccount, web3, startBlockNumber, endBlockNumber) {
  if (endBlockNumber == null) {
    endBlockNumber = web3.eth.blockNumber;
    console.log("Using endBlockNumber: " + endBlockNumber);
  }
  if (startBlockNumber == null) {
    startBlockNumber = endBlockNumber - 10000;
    // startBlockNumber = 1222210;
    console.log("Using startBlockNumber: " + startBlockNumber);
  }
  console.log("Searching for transactions to/from account \"" + myaccount + "\" within blocks "  + startBlockNumber + " and " + endBlockNumber);

  for (var i = endBlockNumber; i >= startBlockNumber; i--) {
    if (i % 1000 == 0) {
      console.log("Searching block " + i);
    }
    var block = web3.eth.getBlock(i, true);
    if (block != null && block.transactions != null) {
      block.transactions.forEach( function(e) {
        if (myaccount == "*" || myaccount == e.from || myaccount == e.to) {
          console.log("  tx hash          : " + e.hash + "\n"
            + "   nonce           : " + e.nonce + "\n"
            + "   blockHash       : " + e.blockHash + "\n"
            + "   blockNumber     : " + e.blockNumber + "\n"
            + "   transactionIndex: " + e.transactionIndex + "\n"
            + "   from            : " + e.from + "\n"
            + "   to              : " + e.to + "\n"
            + "   value           : " + e.value + "\n"
            + "   time            : " + block.timestamp + " " + new Date(block.timestamp * 1000).toGMTString() + "\n"
            + "   gasPrice        : " + e.gasPrice + "\n"
            + "   gas             : " + e.gas + "\n"
            + "   input           : " + e.input);
        }
      })
    }
  }
}
