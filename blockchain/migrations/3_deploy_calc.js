const Calc = artifacts.require("Calculator");

module.exports = function(deployer) {
  deployer.deploy(Calc);
};
