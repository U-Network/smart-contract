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

library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
      c = a + b;
      require(c >= a);
    }
    function sub(uint a, uint b) internal pure returns (uint c) {
      require(b <= a);
      c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
      c = a * b;
      require(a == 0 || c / a == b);
    }
    function div(uint a, uint b) internal pure returns (uint c) {
      require(b > 0);
      c = a / b;
    }
}

interface ERC20Token{
    function totalSupply() public view returns (uint totalUGC);

    function balanceOf(address _owner) public view returns (uint balance);

    function transfer(address _to, uint _value) public returns (bool success);

    function transferFrom(address _from, address _to, uint _value) public returns (bool success);

    function approve(address _spender, uint _value) public returns (bool success);

    function allowance(address _owner, address _spender) public view returns (uint remaining);

    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

contract StandardToken is ERC20Token {
    using SafeMath for uint;

    bool public locked;
    
    uint internal totalUGC;
    mapping (address => uint) internal balances;
    mapping (address => mapping (address => uint)) internal allowed;

    function totalSupply() public view returns (uint) {
        return totalUGC;
    }

    function balanceOf(address _owner) public view returns (uint balance) {
        return balances[_owner];
    }

    function transfer(address _to, uint _value) public returns (bool success) {

        require(!locked);

        require(balances[msg.sender] >= _value && _value > 0);
        
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        
        return true;
    }

    function transferFrom(address _from, address _to, uint _value) public returns (bool success) {

        require(!locked);

        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0);
        
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
        
        return true;
    }

    function approve(address _spender, uint _value) public returns (bool success) {
    // To change the approve amount you first have to reduce the addresses`
    //  allowance to zero by calling `approve(_spender, 0)` if it is not
    //  already 0 to mitigate the race condition described here:
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        require(!locked);
        
        if ((_value != 0) && (allowed[msg.sender][_spender] != 0)) {
            revert();
        }

        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint remaining) {
        return allowed[_owner][_spender];
    }
}


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
    
    address public creator;
    mapping (address => uint256) public freezeOf;

    
    event Receive(address from, uint value);
    event Burn(address owner, uint value);
    event Freeze(address from, uint value);
    event Unfreeze(address from, uint value);

    function BitsupToken() public {
        creator = msg.sender;
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
    
    function unlock() public returns (bool success){
        require(msg.sender == creator);
        locked = false;
        return true;
    }
    function () public payable {
         revert();
    }
}
