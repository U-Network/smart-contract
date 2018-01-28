pragma solidity ^0.4.19;

import "./SafeMath.sol";
import "./StandardToken.sol";
import "./Owned.sol";

contract BitsupToken is StandardToken, Owned {
    using SafeMath for uint;
    
    string public name = "Bitsup Token";
    string public symbol = "UGC";
    uint8  public decimals = 18;
    
    
    bool public isDistributedToFoundation = false; 
    uint public foundationAllocation = 5 * 10**16;  // 5% reserved for foundation
    uint public founderAllocation = 10 * 10**16;    // 10% reserved for founder
    uint public distributedTokens = 0;              // availiable tokens

    // multi-sig address
    address public owner = msg.sender;
    address public foundationAddress = 0x0;

    mapping (address => uint256) public freezeOf;

    
    event Receive(address from, uint value);
    event Burn(address owner, uint value);
    event Freeze(address from, uint value);
    event Unfreeze(address from, uint value);

    function BitsupToken(address _foundationAddress) public {
        foundationAddress = _foundationAddress;
        totalUGC = 0;
        locked = true;
    }
    
    /**
     * Issues `_value` new tokens to `_recipient` (_value < 0 guarantees that tokens are never removed)
     *
     * @param _recipient The address to which the tokens will be issued
     * @param _value The amount of new tokens to issue
     * @return Whether the approval was successful or not
     */
    function issue(address _recipient, uint256 _value) onlyOwner public returns (bool success) {

        // Guarantee positive 
        require(_value > 0);

        // Create tokens
        balances[_recipient] += _value;
        totalUGC += _value;

        // Notify listners
        Transfer(0, owner, _value);
        Transfer(owner, _recipient, _value);

        return true;
    }
    

    function freeze(address addr, uint value) public onlyOwner returns (bool success) {
    	require(value > 0 && balances[addr] >= value);
    	balances[addr] = balances[addr].sub(value);
    	freezeOf[addr] = freezeOf[addr].add(value);                
    	Freeze(addr, value);
    	return true;
    }
	
    function unfreeze(address addr, uint value) public onlyOwner returns (bool success) {
    	require(value > 0 && freezeOf[addr] >= value);
    	freezeOf[addr] = freezeOf[addr].sub(value);                
    	balances[addr] = balances[addr].add(value);
    	Unfreeze(addr, value);
	    return true;
    }
    
    function burn(uint value) public returns (bool success) {
    	require(value > 0 && balances[msg.sender] >= value);
        balances[msg.sender] = balances[msg.sender].sub(value);
        totalUGC = totalUGC.sub(value);
        Burn(msg.sender, value);
        return true;
    }
    
    function unlock() onlyOwner public returns (bool success){
        locked = false;
        return true;
    }
    function () public payable {
         revert();
    }
}
