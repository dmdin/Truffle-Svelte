pragma solidity >=0.4.25 <0.7.0;

import { BigFlexToken } from './BigFlexToken.sol';

contract Credit {
    enum Status {Expired, Open, Taken, Finished}
    struct Debt {
        address payable debtor;
        address payable borrower; // Must be sync
        uint debtorIndex;
        uint borrowerIndex;       // Must be sync
        uint sum;
        uint bonus;
        uint untilDate;
        uint creationDate;
        Status status;            // Must be sync
    }

    Debt debt;
    Debt debtA;
    Debt debtB;
    mapping(address => Debt[]) credits;

    BigFlexToken _token = new BigFlexToken("qwe", "w", 1000, 1, address(this));

    constructor() public {
        _token.send(msg.sender, 500, msg.data);
    }


    function tokenBalance(address wallet) external view returns(uint256) {
        return _token.balanceOf(wallet);
    }

    function createDebt(uint256 sum, uint256 bonus, uint period) payable public returns (address, address, uint, uint, uint, uint, Status){
        require(_token.balanceOf(msg.sender) >= sum, "Err. There isn't enough tokens to create debt");
        debt = Debt(address(0), msg.sender, 0, credits[msg.sender].length, sum, bonus, block.timestamp + period, block.timestamp, Status.Open);
        credits[msg.sender].push(debt);
        _token.operatorSend(msg.sender, address(this), sum, msg.data, msg.data);
        return (debt.debtor, debt.borrower, debt.sum, debt.bonus, debt.untilDate, debt.creationDate, debt.status);
    }

    function getLength(address user) public returns (uint) {
        return credits[user].length;
    }

    function getDebts(address user, uint index) public returns (address, address, uint, uint, uint, uint, Status) {
        debt = credits[user][index];
        return (debt.debtor, debt.borrower, debt.sum, debt.bonus, debt.untilDate, debt.creationDate, debt.status);
    }

    function useDebt(address user, uint index) public payable returns (address, address, uint, uint, uint, uint, Status) {
        debt = credits[user][index];
        require(debt.status == Status.Open, "Debt is not allowed");
        debt.status = Status.Taken;
        debt.debtor = msg.sender;
        debt.debtorIndex = credits[msg.sender].length;
        credits[user][index] = debt;
        credits[msg.sender].push(debt);
        _token.send(msg.sender, debt.sum, msg.data);
        return (debt.debtor, debt.borrower, debt.sum, debt.bonus, debt.untilDate, debt.creationDate, debt.status);
    }

    // Synchronize A with B
    function synchronize(address userA, uint indexA, address userB, uint indexB) private {
        debtA = credits[userA][indexA];
        debtB = credits[userB][indexB];
        debtB.status = debtA.status;
        debtB.debtor = debtA.debtor;
        debtB.debtorIndex = debtA.debtorIndex;
        credits[userB][indexB] = debtB;
    }

    function returnDebt(uint index, uint256 value) public payable {
        debt = credits[msg.sender][index];
        require(debt.bonus + debt.sum <= _token.balanceOf(msg.sender), "Not enough money to return");
        _token.operatorSend(msg.sender, debt.borrower, value, msg.data, msg.data);
        debt.status = Status.Finished;
        credits[msg.sender][index] = debt;
        if (msg.sender == debt.borrower) {
            // Sync if borrower returns his taken credit
            credits[msg.sender][debt.debtorIndex] = debt;
        }
        synchronize(msg.sender, index, debt.borrower, debt.borrowerIndex);
    }

    function debtExpired(address user, uint index) public {
        debt = credits[user][index];
        require(debt.status != Status.Finished, "Debt is Finished");
        debt.status = Status.Expired;
        credits[user][index] = debt;

        if (debt.debtor == user && index == debt.debtorIndex) {
            synchronize(user, index, debt.borrower, debt.borrowerIndex);
        } else {
            synchronize(debt.debtor, debt.debtorIndex, user, index);
        }
    }
}
