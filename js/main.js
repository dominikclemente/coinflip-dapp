var web3 = new Web3(Web3.givenProvider);
var contractInstance;

$(document).ready(function(){
    window.ethereum.enable().then(function (accounts){
        contractInstance = new web3.eth.Contract(abi, '0xE04Ec12Fac12255F00D1F80E7631D5D576a6a88e', {from: accounts[0]});
        console.log(contractInstance);
    });
    $('#bet_button').click(bet);
});

function bet(){
    var betAmount = $("#name_input").val();

    var config = {
        value: web3.utils.toWei(betAmount.toString(), "ether")
    }
    contractInstance.methods.flip().send(config);
}