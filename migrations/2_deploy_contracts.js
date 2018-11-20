var caelumToken = artifacts.require("./mockToken.sol");
var caelumLottery = artifacts.require("./CaelumLottery.sol");

module.exports = function(deployer) {
  deployer.deploy(caelumToken);
  deployer.deploy(caelumLottery);
};
