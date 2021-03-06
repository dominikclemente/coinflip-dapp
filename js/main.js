var web3 = new Web3(Web3.givenProvider);
var contractInstance;

$(document).ready(function(){
    window.ethereum.enable().then(function (accounts){
        contractInstance = new web3.eth.Contract(abi, '0xc1a0F571c1606666AD99287dDb7D2D8E5d0be745', {from: accounts[0]});
        console.log(contractInstance);
    });
    $('#bet_button').click(bet);


    $('#name_input').keypress(function(e){
        if(e.keyCode==13)
        $('#bet_button').click();
    });
});

async function bet(){
    var betAmount = $("#name_input").val();

    $("#bet_result").text("Confirm transaction through MetaMask");

    var config = {
        value: web3.utils.toWei(betAmount.toString(), "ether"),
        gas: 200000
    }

    // We're always betting for heads
    var play = 1;

    contractInstance.methods.play(play).send(config)
    .on('transactionHash', function (hash) {
        console.log("tx hash", hash);
        $("#bet_result").text("Waiting for the transaction to be processed");
    })
    .on('confirmation', function (confirmationNumber, receipt) {
        $("#bet_result").text("Transaction Confirmed");
        console.log("conf", confirmationNumber);
    })
    .on('receipt', function (receipt) {
        console.log(receipt);
        setTimeout(
            function() 
            {
                $("#bet_result").text("Waiting to get result from oracle....");
            }, 5000);

        contractInstance.once('userWon', {
            filter: {
                queryId: queryId
            },
            fromBlock: 0,
            toBlock: 'latest'
        }, function (error, event) {
            console.log("userWon event", event)
            console.log("test event.returnValues.queryId:", event.returnValues.queryId)

            if (event.returnValues.won) {
                $("#bet_result").text("You won " + betPrize.toString() + " ETH!");
            }
            else {
                $("#bet_result").text("You lost " + betPrize.toString() + " ETH");
            }
        });
    })
}