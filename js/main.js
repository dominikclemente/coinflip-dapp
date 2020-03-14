var web3 = new Web3(Web3.givenProvider);
var contractInstance;

$(document).ready(function(){
    window.ethereum.enable().then(function (accounts){
        contractInstance = new web3.eth.Contract(abi, '0xA0d045A0F6c0b2bF7B53381A2e3d17E2E16Af92B', {from: accounts[0]});
        console.log(contractInstance);
    });
    $('#bet_button').click(bet);
});

async function bet(){
    var betAmount = $("#name_input").val();

    var config = {
        value: web3.utils.toWei(betAmount.toString(), "ether"),
        gas: 100000
    }

    try {
    let res = await contractInstance.methods.flip().send(config);
        try{
            await contractInstance.getPastEvents(['bet'], {fromBlock: 'latest', toBlock: 'latest'},
            async (err, events) => {
                console.log(events[0].returnValues);
                betResult = events[0].returnValues['success'];
                console.log(betResult);
            });            
        }catch(err){
        console.log(err)
        }
    }catch(err){
        console.log(err)
    }

}