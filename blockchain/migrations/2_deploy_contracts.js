const Credit = artifacts.require("Credit");
const Token = artifacts.require("BigFlexToken");

module.exports = function(deployer) {
  deployer.deploy(Token, "Big Flex Token", "BFT", 10000, 1).then(() => {
    return deployer.deploy(Credit, Token.address);
  });
};
