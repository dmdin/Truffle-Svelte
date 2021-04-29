pragma solidity 0.6.1;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Credit.sol";


contract TestCredit {
    Credit credit = Credit(DeployedAddresses.Credit());
    address sender = address(this);
    bool success;
    uint256 debtSum = 500;
    uint256 debtBonus = 20;
    function testGetInitialSupply() public {
        // Проверка, что все токены изначально отдаются msg.sender
        Assert.equal(credit.tokenBalance(msg.sender), 500000, "Balance != initSupply");
    }

    function testGetInitialLength() public {
        // Проверка, что изначальное кол-во кредитов == 0
        Assert.equal(credit.getLength(msg.sender), 0, "Initial debt length != 0");
    }

    function testCreateDebt() public {
        credit.giveTokens();
        uint256 senderBalance = credit.tokenBalance(sender);

//         Проверка, что нельзя создать кредит с большим кол-вом токенов, чем на балансе
        try credit.createDebt(1000001, debtBonus, 200) {
            success = true;
        } catch {
            success = false;
        }
        Assert.isFalse(success, "Debt with huge amount of tokens was created");

        // Проверка, что кредит с валидными аргументами создается
        try credit.createDebt(debtSum, debtBonus, 200) {
            success = true;
        } catch {
            success = false;
        }
        Assert.isTrue(success, "Debt wasn't created");

        // Проверка, что правильное кол-во токенов отправляется с баланса создателя кредита
        Assert.equal(credit.tokenBalance(sender), senderBalance - debtSum, "Incorrect token sending");

        // Проверка, что токены пришли на баланс контракта
        Assert.equal(credit.tokenBalance(DeployedAddresses.Credit()), debtSum, "Tokens wasn't delivered to Credit");

        // Проверка, что есть кредит
        Assert.equal(credit.getLength(sender), 1, "Amount of debts is incorrect");
    }

    function testGetDebts() public {
        // Проверка на возврат кредита при невалидном индексе
        try credit.getDebts(sender, credit.getLength(sender)) {
            success = true;
        } catch {
            success = false;
        }
        Assert.isFalse(success, "Doesn't fall with non-valid index");

        // Проверка на возврат кредита при валидном индексе
        try credit.getDebts(sender, 0) {
            success = true;
        } catch {
            success = false;
        }
        Assert.isTrue(success, "Doesn't return debt");
    }

    function testUseDebt() public {
        uint256 creditBalance = credit.tokenBalance(DeployedAddresses.Credit());
        uint256 senderBalance = credit.tokenBalance(sender);

        // Проверка на использование кредита при невалидном индексе
        try credit.useDebt(sender, credit.getLength(sender)) {
            success = true;
        } catch {
            success = false;
        }
        Assert.isFalse(success, "Doesn't fall with non-valid index");

        // Проверка на использование кредита при валидном индексе
        try credit.useDebt(sender, 0) {
            success = true;
        } catch {
            success = false;
        }
        Assert.isTrue(success, "Doesn't take new credit");

        // Проверка пересылки токенов при взятии кредита
        Assert.equal(credit.tokenBalance(DeployedAddresses.Credit()), creditBalance - debtSum, "Tokens didn't send from credit");
        Assert.equal(credit.tokenBalance(sender), senderBalance + debtSum, "Sender didn't get the tokens");

        // Попытка использовать уже взятый контракт
        try credit.useDebt(sender, 0) {
            success = true;
        } catch {
            success = false;
        }
        Assert.isFalse(success, "Using of non-open credit");
    }

    function testReturnDebt() public {
        uint256 senderBalance = credit.tokenBalance(sender);
        // Проверка возврата кредита при невалидном индексе
        try credit.returnDebt(credit.getLength(sender)) {
            success = true;
        } catch {
            success = false;
        }
        Assert.isFalse(success, "Doesn't fall with non-valid index");

        // Проверка возврата кредита при валидном индексе
        try credit.returnDebt(0) {
            success = true;
        } catch {
            success = false;
        }
        Assert.isTrue(success, "Doesn't take new credit");
        // Проверка, что пересылка корректна (так как возвращаем сами себе, баланс не меняется)
        Assert.equal(senderBalance, credit.tokenBalance(sender), "Incorrect transfer of tokens");
    }

    function testDebtExpired() public {
        // Проверка, можно ли объявить истекшим возвращенный кредит
        credit.createDebt(100, 10, 200);
        credit.useDebt(sender, credit.getLength(sender)-1);
        credit.returnDebt(credit.getLength(sender)-1);
        try credit.debtExpired(sender, credit.getLength(sender)-1) {
            success = true;
        } catch {
            success = false;
        }
        Assert.isFalse(success, "Debt was expired after returning");

        // Проверка при невалидном индексе
        try credit.debtExpired(sender, credit.getLength(sender)) {
            success = true;
        } catch {
            success = false;
        }
        Assert.isFalse(success, "Doesn't fall with non-valid index");
    }
}



