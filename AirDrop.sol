
pragma solidity ^0.4.19;

interface UNetworkToken {
    function transfer (address receiver, uint amount) public;
}


contract AirDrop {

	UNetworkToken UUU;
	address[] recipients;
	uint256[] values;

	
	function AirDrop(address _tokenAddress, address[] _recipients, uint256[] _values) public {
		require(_recipients.length == _values.length);
		UUU = UNetworkToken(_tokenAddress);
		recipients = _recipients;
		values = _values;
	}

	function drop() public {
	    for (uint256 i = 0; i < recipients.length; i++) {
	    	UUU.transfer(recipients[i], values[i] * 10 ** 18);
	    }
	}
}