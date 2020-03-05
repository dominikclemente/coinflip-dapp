import "./Ownable.sol";

pragma solidity 0.5.12;

contract Coinflip is Ownable {
    uint public contractBalance;

    event bet(address user, uint bet, bool);

    event funded(address owner, uint funding);

    modifier costs(uint cost) {
        require(msg.value >= cost && msg.value >= 0.01 ether, "The minimum bet is 0.01 Ether");
        _; 
    }
    
    function flip() public payable costs(0.01 ether) returns(bool){
        require(address(this).balance >= msg.value, "The contract doesn't have enough funds");
        bool success;

        if (now % 2 == 0){
            contractBalance += msg.value;
            success = false;
        }

        else {
            contractBalance -= message.value;
            msg.sender.transfer(msg.value * 2);
            success = true;
        }

        emit bet(msg.sender, msg.value, success);
        return success;
    }

    function withdrawAll () public onlyOwner{

    }
}