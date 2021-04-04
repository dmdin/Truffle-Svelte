pragma solidity >=0.4.25 <0.7.0;

contract Credit {
    enum Status {Expired, Open, Taken, Finished}
    struct Debt {
        address payable debtor;
        address payable borrower;
        uint sum;
        uint plus;
        uint untilDate;
        uint creationDate;
        Status status;
    }

    Debt debt;
    Debt checkDebt;
    mapping(address => Debt[]) credits;
    mapping(address => uint) rank;

    function createDebt(uint plus, uint period) payable public returns (address, address, uint, uint, uint, uint, Status){
        debt = Debt(address(0), msg.sender, msg.value, plus, block.timestamp + period, block.timestamp, Status.Open);
        credits[msg.sender].push(debt);
        return (debt.debtor, debt.borrower, debt.sum, debt.plus, debt.untilDate, debt.creationDate, debt.status);
    }

    function getLength(address user) public returns (uint) {
        return credits[user].length;
    }

    function getDebts(address user, uint index) public returns (address, address, uint, uint, uint, uint, Status) {
        debt = credits[user][index];
        return (debt.debtor, debt.borrower, debt.sum, debt.plus, debt.untilDate, debt.creationDate, debt.status);
    }

    function useDebt(address user, uint index) public payable returns (address, address, uint, uint, uint, uint, Status) {
        debt = credits[user][index];
        require(debt.status == Status.Open, "Debt is not allowed");
        debt.status = Status.Taken;
        debt.debtor = msg.sender;
        credits[user][index] = debt;
        credits[msg.sender].push(debt);
        msg.sender.transfer(debt.sum);
        return (debt.debtor, debt.borrower, debt.sum, debt.plus, debt.untilDate, debt.creationDate, debt.status);
    }

    function synchronize(address user, uint index) private{
        debt = credits[user][index];
        for (uint i = 0; i < credits[debt.borrower].length; i++) {
            checkDebt = credits[debt.borrower][i];
            if (checkDebt.sum != debt.sum){
                continue;
            }
            if (checkDebt.plus != debt.plus){
                continue;
            }
            if (checkDebt.creationDate != debt.creationDate){
                continue;
            }

//            if (checkDebt.debtor == address (0))
//            TODO double side sync
            credits[debt.borrower][i] = debt;
            break;
        }
    }
    function returnDebt(uint index) public payable {
        debt = credits[msg.sender][index];
        debt.borrower.transfer(msg.value);
        debt.status = Status.Finished;
        credits[msg.sender][index] = debt;
        synchronize(msg.sender, index);
    }

    function debtExpired(address user, uint index) public returns (bool success){
        debt = credits[user][index];
        if (debt.status != Status.Finished){
            debt.status = Status.Expired;
            synchronize(user, index);
        }
        return true;
    }
}
