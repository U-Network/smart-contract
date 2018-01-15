pragma solidity ^0.4.19;

contract Owned {

    address public owner;

    event ChangeOwner(address indexed previousOwner, address indexed newOwner);

    function Owned() public {
        owner = msg.sender;
    }

    function changeOwner(address _owner) public onlyOwner {
        require(_owner != address(0));
        owner = _owner;
        ChangeOwner(owner, _owner);
    }

    modifier onlyOwner { 
        require(msg.sender == owner);
        _; 
    }
}
