const RINKEBY_MEDIAN = 20000000000;
const ROPSTEN_MEDIAN = 40000000000;
const MAINNET_MEDIAN = 40000000000;
const TRUFFLE_DEFAULT = 100000000000;
const GAS_LIMIT = 4712380;

var approxDeployCost = .15 * 10e18; // Wei

module.exports = {
  networks: {
    testrpc: {
      host: "localhost",
      port: 8600,
      network_id: "*" // Match any network id
    },
    ropsten: {
      host: "localhost",
      port: 8501,
      network_id: 3,
      gas: 4000000,
      gasPrice: ROPSTEN_MEDIAN/2,
    },
    rinkeby: {
      host: "localhost",
      port: 8502,
      network_id: 4,
      gas: GAS_LIMIT,
      gasPrice: 4*RINKEBY_MEDIAN,
    },
    mainnet: {
      host: "localhost",
      port: 8545,
      network_id: 1,
      gas: GAS_LIMIT,
      gasPrice: MAINNET_MEDIAN/2,
    },
  }
};
/*
InterCrypto.at(InterCrypto.address).sendToOtherBlockchain('ltc', 'LbZcDdMeP96ko85H21TQii98YFF9RgZg3D', {value:web3.toWei(0.01, 'ether')}).then(function(tx) { console.log(tx.logs[0].args.value); });
*/
