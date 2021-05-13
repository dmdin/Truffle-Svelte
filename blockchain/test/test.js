const Credit = artifacts.require('Credit')
var assert = require('chai').assert
var expect = require('chai').expect


contract('Credit', (accounts) => {
    let tempcredit;
    var mainAccount = accounts[0];
    const sum = 100
    const bonus = 100
    const period = 4
    before( async () => {
        tempcredit = await Credit.deployed();
    })
    
    describe('when we create contract firstly', () => {
        it('it should be 500000 bigflextokens on account', async function(){
            const count = await tempcredit.tokenBalance(mainAccount);
            expect(count.valueOf().toNumber()).to.be.eq(500000, "there is no 500000 bigflextokens on account");
        })
    });

   describe('when debt is create', () =>{
        it('should send less tokens than 500000', async function(){
            var pass = true
            try {
                await tempcredit.createDebt(sum, bonus, period)
            } catch (error) {
                pass = false
            }
            assert.isTrue(pass, 'not enough tokens to create debt')
        })
        it('should send tokens from sender', async function(){
            const senderBalance = (await tempcredit.tokenBalance(mainAccount)).toNumber()
            await tempcredit.createDebt(sum, bonus, period)
            assert.equal((await tempcredit.tokenBalance(mainAccount)).toNumber(), senderBalance - sum, 'tokens not sending')
        })
    })
})
