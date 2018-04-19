
pragma solidity ^0.4.19;

interface UNetworkToken {
	mapping (address => uint256) public balanceOf;
    function transfer(address _to, uint256 _value) public;
}


contract AirDrop {

	UNetworkToken UUU;
	address public owner;

	uint256 public value = 0;

	function AirDrop() public {
		UUU = UNetworkToken(0x3543638eD4a9006E4840B105944271Bcea15605D);
		owner = msg.sender;
	}

	function unfreeze() public {
		require(msg.sender == owner);	
	    for (uint256 i = 0; i < recipients.length; i++) {
	    	UUU.transfer(recipients[i], value * 10 ** 18);
	    }
	}

	// in case of balance surplus. Return remaining UUU.
	function refund() public {
		require (msg.sender == owner);
		UUU.transfer(owner, 100000 * 10**18);
	}
}