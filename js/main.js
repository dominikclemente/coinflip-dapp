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

    $("#bet_result").text("Confirm transaction through MetaMask");

    var config = {
        value: web3.utils.toWei(betAmount.toString(), "ether"),
        gas: 200000
    }

    try {
        $("#bet_result").text("Waiting for the transaction to go through");
        let res = await contractInstance.methods.flip().send(config);
            try{
                $("#bet_result").text("Waiting to get result from our wise oracle...");
                await contractInstance.getPastEvents(['betTaken'], {fromBlock: 7590043, toBlock: 'latest'},
                async (err, events) => {
                    console.log(events);
                    /*
                    betResult = events[0].returnValues['result'];
                    if (betResult) {
                        $("#bet_result").text("You won " + betPrize.toString() + " ETH!");
                    }
                    else {
                        $("#bet_result").text("You lost " + betPrize.toString() + " ETH");
                    }
                    */
                });            
            }catch(err){
            console.log(err)
            }
        }catch(err){
            console.log(err)
        }
}