var InterCrypto = artifacts.require("./InterCrypto.sol")

module.exports = function(deployer) {
  deployer.deploy(InterCrypto);
};
