var BaseContract = artifacts.require("./BaseContract.sol");

module.exports = function(deployer) {
  deployer.deploy(BaseContract);
};
