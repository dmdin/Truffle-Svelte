const Token = artifacts.require("BigFlexToken");
const Credit = artifacts.require("Credit");

module.exports = function(deployer) {
  deployer.deploy(Credit);
};
