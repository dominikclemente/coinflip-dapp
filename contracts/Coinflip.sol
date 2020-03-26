import "./Ownable.sol";
import "./provableAPI.sol";

pragma solidity 0.5.12;

contract Coinflip is Ownable, usingProvable {
    uint256 public unlockedBalance;

    mapping(address => uint256) public playersCollectablePrizes;
    mapping(bytes32 => address) public QueryIdPlayer;
    mapping(address => bytes32) public PlayerQueryId;
    mapping(address => uint256) public playersLastBet;
    mapping(address => uint256) public playersLastPlay;
    mapping(address => bool) public isPlayerWaiting;
    mapping(address => uint256) public playersPotentialWinnings;

    uint256 constant NUM_RANDOM_BYTES_REQUESTED = 1;

    event userWon(bytes32 indexed queryId, address player, uint256 prize, bool won);

    // Provable Events
    event logNewProvableQuery(string description);
    event generatedRandomNumber(uint256 randomNumber);
    event logQueryId(address player, bytes32 queryId);

    constructor () public {
        getRandomFromOracle();
    }

    modifier minimumBet(uint256 betValue) {
        require(betValue >= 1 wei, "minimum play is 1 wei");
        _;
    }

    function __callback(
        bytes32 _queryId,
        string memory _result,
        bytes memory _proof
    ) public {
        require(msg.sender == provable_cbAddress());

        uint256 randomNumber = uint256(keccak256(abi.encodePacked(_result))) %
            2;
        emit generatedRandomNumber(randomNumber);
        processResult(randomNumber, _queryId);
    }

    function processResult(uint256 randomNumber, bytes32 queryId) internal {
        address playerAddress = QueryIdPlayer[queryId];
        require(isPlayerWaiting[playerAddress], "user was not waiting for a result...");
        uint256 userPrize = playersPotentialWinnings[playerAddress];
        if (randomNumber == playersLastPlay[playerAddress]) {
            // user wins
            playersCollectablePrizes[playerAddress] += userPrize;
            playersPotentialWinnings[playerAddress] = 0;
            // didPlayerWon[playerAddress] = true;
            emit userWon(queryId, playerAddress, userPrize, true);
        } else {
            playersPotentialWinnings[playerAddress] = 0;
            unlockedBalance += userPrize;
            // didPlayerWon[playerAddress] = false;
            emit userWon(queryId, playerAddress, userPrize, false);
        }
        isPlayerWaiting[playerAddress] = false;
    }

    function getRandomFromOracle() public payable returns (bytes32 queryId) {
        uint256 QUERY_EXECUTION_DELAY = 0;
        uint256 GAS_FOR_CALLBACK = 200000;
        queryId = provable_newRandomDSQuery(
            QUERY_EXECUTION_DELAY,
            NUM_RANDOM_BYTES_REQUESTED,
            GAS_FOR_CALLBACK
        );

        emit logNewProvableQuery(
            "Provable query sent; waiting for callback..."
        );
        emit logQueryId(msg.sender, queryId);
        return queryId;
    }

      function getCollectablePrizes() public returns (uint256 balance) {
        return playersCollectablePrizes[msg.sender];
    }

    function collectPrizes() public returns (uint256 collected) {
        uint256 toTransfer = playersCollectablePrizes[msg.sender];
        playersCollectablePrizes[msg.sender] = 0;
        msg.sender.transfer(toTransfer);
        return toTransfer;
    }

    function getLatestQueryId()
        public
        returns (bytes32 queryID)
    {
        return PlayerQueryId[msg.sender];
    }

    function play(uint256 userPlay)
        public
        payable
        minimumBet(msg.value)
        returns (bytes32 queryID)
    {

        if (userPlay != 0 && userPlay != 1) {
            revert("Please chose 1 or 0 as input");
        } else {
            playersLastBet[msg.sender] = msg.value;
            playersPotentialWinnings[msg.sender] = unlockedBalance;
            unlockedBalance = msg.value; // pool is never 0...all bets always goes to pool, even if user wins.
            isPlayerWaiting[msg.sender] = true;
            playersLastPlay[msg.sender] = userPlay;
            queryID = getRandomFromOracle();
            QueryIdPlayer[queryID] = msg.sender;
            PlayerQueryId[msg.sender] = queryID;
            return queryID;
        }
    }
}