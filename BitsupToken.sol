pragma solidity ^0.4.19;

import "./SafeMath.sol";
import "./StandardToken.sol";
import "./Owned.sol";

contract BitsupToken is StandardToken, Owned {
    using SafeMath for uint;
    
    string public name = "Bitsup Token";
    string public symbol = "UGC";
    uint8 public decimals = 18;
    
    uint public startBlock;
    uint public endBlock;
    
    bool public halted = false;
    
    bool public isDistributedToFoundation = false; 
    uint public foundationAllocation = 5 * 10**16;  // 5% reserved for foundation
    uint public founderAllocation = 10 * 10**16;    // 10% reserved for founder
    uint public distributedTokens = 0;              // availiable tokens

    // multi-sig address
    address public owner = msg.sender;
    address public foundationAddress = 0x0;
    
    event Receive(address from, uint value);
    event Burn(address owner, uint value);

    function BitsupToken(address _owner, uint _startBlock, uint _endBlock) public {
        if (_owner != 0x0) owner = _owner;
        startBlock = _startBlock;
        endBlock = _endBlock;
        totalSupply = 10000 * 10**uint(decimals);
        balances[owner] = totalSupply * founderAllocation / (1 ether);
    }
    
    function reservedForFoundation(address _foundationAddress) public onlyOwner {
        require(_foundationAddress != 0x0 && isDistributedToFoundation == false);
        foundationAddress = _foundationAddress;
        balances[foundationAddress] = totalSupply * foundationAllocation / (1 ether);
        isDistributedToFoundation = true;
    }
    
    function price() public pure returns (uint) {
        return 100;
    }
    
    function buy() public payable {
        // require(block.number >= startBlock && block.number <= endBlock && !halted && msg.value >0);
        require(!halted && msg.value >0);
        uint tokenNum = msg.value * price();
        distributedTokens += tokenNum;
        require(distributedTokens <= totalSupply * (1 ether - foundationAllocation - founderAllocation) / (1 ether));
        balances[msg.sender] = balances[msg.sender].add(tokenNum);
        owner.transfer(msg.value);
        Receive(msg.sender, msg.value);
    }
    
    function start() public onlyOwner {
        halted = false;
    }

    function stop() public onlyOwner {
        halted = true;
    }
    
    function burn(uint value) public returns (bool success) {
	require(value > 0 && balances[msg.sender] >= value);
        balances[msg.sender] = balances[msg.sender].sub(value);
        totalSupply = totalSupply.sub(value);
        Burn(msg.sender, value);
        return true;
    }

    function changeOwner(address _owner) public onlyOwner {
        owner = _owner;
    }
    
    function transfer(address _to, uint _value) public returns (bool) {
        if (block.number <= endBlock && msg.sender != owner) revert();
        return super.transfer(_to, _value);
    }
    
    function transferFrom(address _from, address _to, uint _value) public returns (bool) {
       if (block.number <= endBlock && msg.sender != owner) revert();
        return super.transferFrom(_from, _to, _value);
    }

    function () public payable {
         revert();
    }
}
