
pragma solidity ^0.4.19;

contract UNetworkToken {
    function transfer(address _to, uint256 _value) public;
    mapping (address => uint256) public balanceOf;
}

contract TokenTimelock {

  UNetworkToken UUU;

  // beneficiary of tokens after they are released
  address public beneficiary;

  // timestamp when token release is enabled
  uint256 public releaseTime;

  function TokenTimelock(address _beneficiary, uint256 _releaseTime) public {
    // solium-disable-next-line security/no-block-members
    require(_releaseTime > block.timestamp);
    UUU = UNetworkToken(0x3543638eD4a9006E4840B105944271Bcea15605D);
    beneficiary = _beneficiary;
    releaseTime = _releaseTime;
  }

  /**
   * @notice Transfers tokens held by timelock to beneficiary.
   */
  function release() public {
    // solium-disable-next-line security/no-block-members
    require(block.timestamp >= releaseTime);

    uint256 amount = UUU.balanceOf(this);
    require(amount > 0);

    UUU.transfer(beneficiary, amount);
  }
}
