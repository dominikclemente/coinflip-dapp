pragma solidity 0.5.12;

contract Ownable {

    address public contractOwner;

//** Constructor Section */
    constructor() public{
        contractOwner = msg.sender;
    }
//** Modifier Section */
// Only Owner of the Contract can execute the function modifier
    modifier onlyOwner() {
        require(msg.sender == contractOwner, "You are not entitled to execute this function.");
        _;
    }
//** Setter Function Section */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        contractOwner = newOwner;
    }

}
