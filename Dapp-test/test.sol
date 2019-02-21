pragma solidity ^0.5.0;

contract test {
    uint256 public num;
    function set(uint256 _num) public {
        num = _num;
    }
    function get() public view returns(uint256){
        return num;
    }
}