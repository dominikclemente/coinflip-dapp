const coinflipContract = artifacts.require("Coinflip");
const truffleAssert = require("truffle-assertions");

contract("Coinflip", async accounts => {
    let instance;

    before(async () => {
        instance = await coinflipContract.deployed();
    });

    it("shouldn't be able to bet an amount smaller than 0.01 ether", async () => {
        await truffleAssert.fails(instance.flip({value: web3.utils.toWei("0.003", "ether"), from: accounts[1]}), truffleAssert.ErrorType.REVERT);
    });

    it("should be possible to bet an amount of 0.01 Ether or higher", async function(){
        await truffleAssert.passes(instance.flip({value: web3.utils.toWei("0.01","ether"), from:accounts[1]}), truffleAssert.ErrorType.REVERT);
    }); 
    // TODO: We get the current balance of the contract add one to it and try to withdraw that amount expecting an error
    //it("shouldn't be possible make higher bad as contract funding", async function(){
    //    await truffleAssert.fails(instance.flip({value: web3.utils.toWei("200","ether"), from:accounts[0]}), truffleAssert.ErrorType.REVERT);
    //});

    it("shouldn't be able to withdraw the funds of the contract from a non-owner address", async () =>{
        await truffleAssert.fails(instance.withdrawAll({from: accounts[1]}), truffleAssert.ErrorType.REVERT);
    });

    it("should be possible to withdraw funds from contract owner address", async () => {
        await truffleAssert.passes(instance.withdrawAll({from: accounts[0]}), truffleAssert.ErrorType.REVERT);
    });
});