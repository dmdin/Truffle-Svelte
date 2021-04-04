pragma solidity >=0.4.25 <0.7.0;

contract Credit {

    struct Debt {
        address debtor;
        address borrower;
        uint sum;
        uint untilDate;
        uint creationDate;
        bool expired;
    }

    Debt debt;
    mapping(address => Debt[]) credits;
    mapping(address => uint) rank;

    function createDebt(uint _sum, uint period) public returns (address, address, uint, uint, uint, bool){
        debt = Debt(msg.sender, address(0), _sum, block.timestamp + period, block.timestamp, false);
        credits[msg.sender].push(debt);
        return (debt.debtor, debt.borrower, debt.sum, debt.untilDate, debt.creationDate, debt.expired);
    }

    function getLength(address user) public returns (uint) {
        return credits[user].length;
    }

    function getDebts(address user, uint index) public returns (address, address, uint, uint, uint, bool) {
        debt = credits[user][index];
        return (debt.debtor, debt.borrower, debt.sum, debt.untilDate, debt.creationDate, debt.expired);
    }
}
