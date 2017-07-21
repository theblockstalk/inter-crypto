var InterCrypto = artifacts.require("./InterCrypto.sol");
const helpers = require('./lib/test_helpers.js');

// const TRUFFLE_DEFAULT_gas = 4712388; // this is also the gasLimit
// const TRUFFLE_DEFAULT_gasPrice = 100000000000;
const MOCHA_DEFAULT_TIMEOUT = 300000;
/*
describe('Ethereum block number test', function() {
  it('Ethereum node is at head',function(done) {
    helpers.checkLocalBlockAgainstAPI(done);
  })
})


contract('InterCrypto', function(accounts) {
  console.log('\n');

  var intercryptoAddress = InterCrypto.address;
  var dateStringISO = new Date().toISOString();
  helpers.printConractToLog(intercryptoAddress, dateStringISO);

  //________________CONTRACT DATA STRUCTURES______________________
  var Status = {
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

  //________________TESTING FUNCTIONS______________________
  it("getInfoFunction logs information", function(done) {
    // helpers.getInfoTest(done, InterCrypto, accounts);
    done();
  })

  it("eth.accounts[0] is owner of contract", function(done) {
    // helpers.ownerTest(done, InterCrypto, accounts);
    done();
  })

  it("Initially has 0 transactionCount", function(done) {
    // helpers.getNumberOfTransactionsTest(done, InterCrypto);
    done();
  })

  it('get Price of Oracalize', function(done) {
    // helpers.testGetInterCryptoPrice(done, InterCrypto, accounts);
    done();
  })

  const MULTIPLIER = 2;

  it("Testing inbound Oracalize contract request", function(done) {
    this.timeout(MULTIPLIER*MOCHA_DEFAULT_TIMEOUT);
    setTimeout(done, MULTIPLIER*MOCHA_DEFAULT_TIMEOUT);
    helpers.testOracalizeInboundTest(done, InterCrypto, accounts);
    // done();
  })

  it("Testing outbound Oracalize contract request", function(done) {
    // this.timeout(MULTIPLIER*MOCHA_DEFAULT_TIMEOUT);
    // setTimeout(done, MULTIPLIER*MOCHA_DEFAULT_TIMEOUT);
    // helpers.testOracalizeOutboundTest(done, InterCrypto, accounts, dateStringISO);
    done();
  })

  it("sendToOtherBlockchain() creates first Transaction", function(done) {
    this.timeout(MULTIPLIER*MOCHA_DEFAULT_TIMEOUT);
    setTimeout(done, MULTIPLIER*MOCHA_DEFAULT_TIMEOUT);
    helpers.sendToOtherBlockchainTest(done, InterCrypto, accounts);
    done();
  })

  it("kill() commits suicide", function(done) {
    // helpers.killTest(done, InterCrypto, accounts, intercryptoAddress);
    done();
  })

});
*/
