
pragma solidity ^0.4.19;

interface UNetworkToken {
    function transfer(address _to, uint256 _value) public;
}


contract Fund {

	UNetworkToken UUU;
	address public owner;

	//Unix epoch time for Saturday, September 1, 2018 12:00:00 AM GMT
	uint public first_release = 1535760000;
	//Unix epoch time for Friday, March 1, 2019 12:00:00 AM GMT
	uint public second_release = 1551398400;
	//Set to true after withdraw first half;
	bool public first_release_cashed = false;
	//Set to true after second relase;
	bool public second_release_cashed = false;

	//Amount to release in regular units. 
	uint256 public release_amount = 0;

	function Fund() public {
		UUU = UNetworkToken(0x3543638eD4a9006E4840B105944271Bcea15605D);
		owner = msg.sender;
	}

	//TEST WITH UNITS && TEST ON MAIN NET WITH SMALL AMOUNT OF UUU. 
	function release() public {
		require (msg.sender == owner);
		if (now > first_release && !first_release_cashed) {
			UUU.transfer(owner, release_amount * 10 ** 18);
			first_release_cashed = true;
		}
		if (now > second_release && !second_release_cashed){
			UUU.transfer(owner, release_amount * 10 ** 18);
			second_release_cashed = true;
		}
	}
}