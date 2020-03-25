import "./Ownable.sol";
import "./provableAPI.sol";

pragma solidity 0.5.12;

contract Coinflip is Ownable, usingProvable {

    uint256 constant NUM_RANDOM_BYTES_REQUESTED = 1; // Enough memory to store a number in the 0-255 range
    bytes32 queryId;                                 // Callback ID 
    uint256 public latestNumber;                     // 0 or 1

    struct Bet {
        address payable player; 
        uint value;                 // How much the player is betting
        bool result;                // Result of the bet (0 or 1)
    }

    mapping (bytes32 => Bet) public results;
    mapping (address => bool) public waiting;

    constructor() public {
        provable_setProof(proofType_Ledger);
        update();
    }

    uint public contractBalance;

    event bet(address user, uint bet, bool success);
    event betTaken(address indexed player, bytes32 Id, uint value, bool result);
    event betPlaced(address indexed player,bytes32 queryId, uint value);
    event funded(address owner, uint funding);
    event randomNumberGenerated(uint256 randomNumber);
    event LogNewProvableQuery(string description);

    modifier minimumBet(uint cost){
        require(msg.value >= cost, "The value provided is not enough");
        _;
    }

    function __callback(bytes32 _queryId, string memory _result, bytes memory _proof) public {
        require(msg.sender == provable_cbAddress());

        uint256 randomNumber = uint256(keccak256(abi.encodePacked(_result)));
        latestNumber = randomNumber % 2;

        if (latestNumber == 1) {
            results[_queryId].result = true;
        }
        else {
            results[_queryId].result = false;
            results[_queryId].player.transfer((results[_queryId].value)*2);
        }

        //Player address is not on waiting any more and can play again
        waiting[results[_queryId].player] = false;
        emit randomNumberGenerated(randomNumber);
        emit betTaken(results[_queryId].player, _queryId, results[_queryId].value, results[_queryId].result);
    }

    function update() public payable returns (bytes32) {

        uint256 QUERY_EXECUTION_DELAY = 0;
        uint256 GAS_FOR_CALLBACK = 200000;
        bytes32 id = provable_newRandomDSQuery(QUERY_EXECUTION_DELAY, NUM_RANDOM_BYTES_REQUESTED, GAS_FOR_CALLBACK);

        emit LogNewProvableQuery("Query is on the way, waiting for response");

        return id;
    } 

    function flip() public payable minimumBet(0.01 ether) returns(bool){
        require(address(this).balance >= msg.value, "The contract doesn't have enough funds");

        bool success;

        if(!waiting[msg.sender]){
            contractBalance += msg.value;

            waiting[msg.sender] = true;
            queryId = update();

            uint result = latestNumber;
            emit bet(msg.sender, msg.value, success);

            if (result == 1){
                success = true;
                results[queryId] = Bet({player: msg.sender, value: msg.value, result: true});
                contractBalance -= 2*msg.value;
                msg.sender.transfer(2*msg.value);
            }
            else{
                success = false;
                results[queryId] = Bet({player: msg.sender, value: msg.value, result: false});
            }

            waiting[msg.sender] = false;
            return success;            
        }
        else{
            return false;
        }

        emit bet(msg.sender, msg.value, success);
        emit betPlaced(msg.sender, queryId, msg.value);
        return false;
    }

    function withdrawAll () public onlyOwner returns(uint){
        msg.sender.transfer(address(this).balance);
        assert(address(this).balance == 0);
        return address(this).balance;
    }

    function getBalance() public view returns (address, uint, uint) {
        return(address(this), address(this).balance, contractBalance);
    }

    function fundContract() public payable onlyOwner returns(uint){
        require(msg.value != 0);
        emit funded(msg.sender, msg.value);
        return msg.value;
    }
}