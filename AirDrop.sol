
pragma solidity ^0.4.19;

interface UNetworkToken {
    function transfer (address receiver, uint amount) public;
}


contract AirDrop {

	UNetworkToken UUU;
	
	function AirDrop(address _tokenAddress) public {
		UUU = UNetworkToken(_tokenAddress);
	}

	function drop(address[] recipients, uint256[] values) public {
		require(recipients.length == values.length);
	    for (uint256 i = 0; i < recipients.length; i++) {
	    	UUU.transfer(recipients[i], values[i]);
	    }
	}
}