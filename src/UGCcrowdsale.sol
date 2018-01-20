pragma solidity ^0.4.19;

import "./BitsupToken.sol";

contract UGCcrowdSale {
	address public beneficiary; //Foundation address
	uint256 public softCap = 10000 ether; // Place holders for now
    uint256 public hardCap = 100000 ether; // Place holders for now
    uint256 public minAcceptedAmount = 1 ether; // Place holders for now


    //ETH to UGC conversion rate
    //Dummy values for ETH2UGC conversion rate 
    uint256 public ratePresale = 1;
    uint256 public ratePreICO = 1;
    uint256 public rateICO = 1;

    //Dummy values for different stage length in days
    uint256 public presalePeriod = 1 days;
    uint256 public preICOPeriod = 1 days;
    uint256 public ICOPeriod = 1 days;

    // Crowdsale state
    uint256 public start;
    uint256 public end;

    BitsupToken ugcToken;
    uint256 public raisedSoFar;

    // Investor balances
    mapping (address => uint256) balances;

    /**
     * Revert if sender is not beneficiary
     */
    modifier onlyBeneficiary() {
        if (beneficiary != msg.sender) {
            revert();
        }
        _;
    }

    /** 
     * Get balance of `_investor` 
     * 
     * @param _investor The address from which the balance will be retrieved
     * @return The balance
     */
    function balanceOf(address _investor) constant public returns (uint256 balance) {
        return balances[_investor];
    }

    function UGCcrowdSale(address _tokenAddress, address _beneficiary, uint256 _start) public {
    	ugcToken = BitsupToken(_tokenAddress);
    	beneficiary = _beneficiary;
    	start = _start;
    	end   = start + presalePeriod + preICOPeriod + ICOPeriod;

    }

    function ETH2UGC(uint256 _wei) public pure returns (uint256 amount)  {
    	uint256 dummy_value = _wei; // make compiler happy
    	return dummy_value;
    	//todo
    }
    function () payable public{
    	//todo
    }

}