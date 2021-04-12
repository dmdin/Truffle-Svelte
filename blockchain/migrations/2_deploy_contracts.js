const Credit = artifacts.require("Credit");
const Token = artifacts.require("BigFlexToken");

module.exports = function(deployer) {
  deployer.deploy(Credit);
};
