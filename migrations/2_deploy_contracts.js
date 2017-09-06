var BaseContract = artifacts.require("./BaseContract.sol");
var HolderAdCoins = artifacts.require("./HolderAdCoins.sol");
var PreCATToken = artifacts.require("./PreCATToken.sol");

module.exports = function(deployer) {
  deployer.deploy(PreCATToken);
  deployer.deploy(HolderAdCoins);
  deployer.deploy(BaseContract);
};
