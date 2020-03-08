const coinflipContract = artifacts.require("Coinflip");
const truffleAssert = require("truffle-assertions");

contract("Coinflip", async function(accounts){
    let instance;

    before(async function(){
        instance = await coinflipContract.deployed();
    });

    it("shouldn't be able to bet an amount smaller than 0.01 ether", async function(){
        await truffleAssert.fails(instance.flip({value: web3.utils.toWei("0.003", "ether"), from: accounts[1]}), truffleAssert.ErrorType.REVERT);
    });

    it("should be able to bet an amount higher than 0.01 ether", async function(){
        await truffleAssert.passes(instance.flip({value: web3.utils.toWei("0.01", "ether"), from: accounts[1]}), truffleAssert.ErrorType.REVERT);
    });
// We get the current balance of the contract add one to it and try to withdraw that amount expecting an error
    it("shouldn't be able to bet an amount higher than the total balance of the contract", async function(){
        await truffleAssert.fails(instance.flip({value: instance.getBalance()[2] + web3.utils.toWei("1", "ether"), from: accounts[1]}), truffleAssert.ErrorType.REVERT);
    });

    it("shouldn't be able to withdraw the funds of the contract from a non-owner address", async function(){
        await truffleAssert.fails(instance.witdrawAll({from: accounts[1]}), truffleAssert.ErrorType.REVERT);
    });

    it("should be possible to withdraw funds from contract owner address", async function(){
        await truffleAssert.passes(instance.witdrawAll({from: accounts[0]}), truffleAssert.ErrorType.REVERT);
    });
});