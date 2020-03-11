import "./Ownable.sol";

pragma solidity 0.5.12;

contract Coinflip is Ownable {
    uint public contractBalance;

    event bet(address user, uint bet, bool succes);

    event funded(address owner, uint funding);

    modifier minimumBet(uint cost){
        require(msg.value >= cost, "The minimum bet is 0.01 Ether");
        _;
    }
    
    function flip() public payable minimumBet(0.01 ether) returns(bool){
        require(address(this).balance >= msg.value, "The contract doesn't have enough funds");
        bool success;

        if (now % 2 == 0){
            contractBalance += msg.value;
            success = false;
        }

        else {
            contractBalance -= msg.value;
            msg.sender.transfer(msg.value * 2);
            success = true;
        }

        emit bet(msg.sender, msg.value, success);
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