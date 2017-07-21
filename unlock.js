module.exports = function(callback) {
  var password = null;
  var passwordIndex;

  process.argv.forEach(function (val, index, array) {
    if (val == 'unlock.js')
        passwordIndex = index + 1;
    if (index == passwordIndex)
      password = val
  });

  if (password == null) {
    throw "Accounts password was not supplied";
  }

  detectNetworkAndUnlock(password);
}

function detectNetworkAndUnlock(password) {
  const MAX_ACCOUNT = 2;
  const UNLOCK_SECCONDS = 6000;

  function unlock(maxAccount) {
    for( i = 0; i < maxAccount; i++) {
      var item = web3.eth.accounts[i];
      console.log('Unlocking account: ' + item);
      var didUnlock = web3.personal.unlockAccount(item, password, UNLOCK_SECCONDS);
      if(!didUnlock) throw item + " was NOT unlocked";
    }
  }

  var ethereumNetworkVersion = parseInt(web3.version.network);
  if (ethereumNetworkVersion > 10) {
    console.log('Public blockchain not in use...')
  }
  else {
    switch(ethereumNetworkVersion) {
      case 1:
        console.log('This is mainnet');
        unlock(MAX_ACCOUNT);
        break;
      case 2:
        console.log('This is the deprecated Morden test network.');
        unlock(MAX_ACCOUNT);
        break;
      case 3:
        console.log('This is the Ropsten test network.');
        unlock(MAX_ACCOUNT);
        break;
      case 4:
        console.log('This is the Rinkeby test network.');
        unlock(MAX_ACCOUNT);
        break;
      default:
        throw "Unknown Ethereum network version: " + ethereumNetworkVersion;
    }
  }
}
