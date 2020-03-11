var web3 = new Web3(Web3.givenProvider);
var contractInstance;

$(document).ready(function(){
    window.ethereum.enable().then(function (accounts){
        contractInstance = new web3.eth.Contract(abi, '0xd2ac41e712f94f1B3484C04568Ac47D3304A8561', {from: accounts[0]});
        console.log(contractInstance);
    });
    $('#bet_button').click(bet);
});

function bet(){
    var betAmount = $("#name_input").val();

    var config = {
        value: web3.utils.toWei(betAmount.toString(), "ether"),
        gas: 100000
    }
    contractInstance.methods.flip().send(config);
}