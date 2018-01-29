pragma solidity ^0.4.19;

interface BitsupToken {
    function issue (address receiver, uint amount) public returns (bool success);
}

contract UGCcrowdSale {
	address public beneficiary; //Foundation address
	uint256 public softCap = 10 ether; // Place holders for now
    uint256 public hardCap = 50 ether; // Place holders for now
    uint256 public minAcceptedAmount = 1 ether; // Place holders for now


    //ETH to UGC conversion rate
    //Dummy values for ETH2UGC conversion rate 
    uint256 public ratePresale = 1;
    uint256 public ratePreICO = 1;
    uint256 public rateICO = 1;

    //Dummy values for different stage length in days
    uint256 public presalePeriod = 2 minutes;
    uint256 public preICOPeriod = 2 minutes;
    uint256 public ICOPeriod = 2 minutes;

    // Crowdsale state
    uint256 public start;
    uint256 public end;

    BitsupToken ugcToken;
    uint256 public raisedSoFar;

    // Investor balances in ETH 
    mapping (address => uint256) balances;

    event GoalReached(address beneficiary, uint amountRaised);

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

    /**
     * Constructor
     * @param _tokenAddress The addres of UGC token contract
     */
    function UGCcrowdSale(address _tokenAddress, address _beneficiary, uint256 _start) public {
    	ugcToken = BitsupToken(_tokenAddress);
    	beneficiary = _beneficiary;
    	start = now; //For testing purpose, need to change back to _start
    	end   = start + presalePeriod + preICOPeriod + ICOPeriod;

    }

    /**
     * For testing purposes
     *
     * @return The beneficiary address
     */
    function confirmBeneficiary() public view onlyBeneficiary returns(address confirmedAddr)  {
        return msg.sender;
    }
    /**
     * Internal function that calculates UGC amount given the current rate
     * @param _wei Amount of ETH to convert
     * @return The amount of UGC 
     */
    function ETH2UGC(uint256 _wei) private view returns (uint256 amount)  {
        uint256 rate = 0;
        if(now >= start && now <= end){
            if(now <= start + presalePeriod){
                rate = ratePresale;
            }
            else if(now <= start + presalePeriod + preICOPeriod){
                rate = ratePreICO;
            }
            else if(now <= start + presalePeriod + preICOPeriod + ICOPeriod){
                rate = ICOPeriod;
            }
        }
        return _wei * rate * 10**8 / 1 ether;
        
    }

    /**
     * Receives ETH and reward the sender with UGC
     */
    function () payable public{

        require(now >= start && now <= end);
        
        require(msg.value > minAcceptedAmount);

        require(raisedSoFar + msg.value <= hardCap);

        uint ugcAmount = ETH2UGC(msg.value);

        require(ugcAmount != 0);

        require(ugcToken.issue(msg.sender, ugcAmount));

        balances[msg.sender] += msg.value;

        raisedSoFar += msg.value;
    	
    }

    /**
     * Transfer the raised amount to foundation (Beneficiary)
     */
    function withdraw() public onlyBeneficiary {
        require(raisedSoFar > softCap);

        require(now > end);

        //require UGC is unlocked? Are we locking the token? 

        uint256 ETHbalance = this.balance;

        beneficiary.transfer(ETHbalance);

        GoalReached(beneficiary, ETHbalance);
    }

    /**
     * Refund in the case of an unsuccessful crowdsale. The 
     * crowdsale is considered unsuccessful if softCap is not reached by
     * the end
     */

     function refund()  public {
        require(now >= end);
        require(raisedSoFar < softCap);

        uint256 investedAmount = balances[msg.sender];

        require(investedAmount > 0);

        msg.sender.transfer(investedAmount);

        balances[msg.sender] = 0;
     }
}