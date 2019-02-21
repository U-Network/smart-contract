
/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Questionnaries is Ownable {
//    mapping(uint8 => uint8[]) votes;
    mapping(uint8 => mapping(uint8 => uint256)) votes;
    mapping(address => bool)    voted;
    
    // The "attributes" means the features of this Questionnarie,
    // the first value 'n' represents the amount of the questions
    // the second value 'm' represents a few options for each question,
    // if the value is zero which means different question has 
    // different options. 
    // The third value is 'sum' which represents the sum of the options.
    // The next few values represent the quantity of each question if 
    // the 'm' is zero.
    uint[]  public  attributes;    
    string  public  certification;
                        
    event   Vote(address);
    
    constructor (uint[] memory _attributes, string memory _certification) public {
        attributes = _attributes;
        certification = _certification;
    }
    
    function vote(uint8[] memory _result) public {
        require(!voted[msg.sender], "You have already voted.");
        for(uint8 i = 0; i < _result.length; ++i) {
            votes[i][_result[i]]++;
        }
        voted[msg.sender] = true;
        emit Vote(msg.sender);
    }
/*    
    function kill() onlyOwner public{
        selfdestruct(owner());
    }
*/
    function callResult() view external returns(uint256[] memory) {
        uint256[] memory _result;
        uint256 _sum = attributes[2];
        
        _result = new uint256[](_sum);
        uint256 _rest = _sum;
        
        if (attributes[1] == 0) {
            for(uint8 i = 0; i < attributes[0]; ++i) {
                for(uint8 j = 0; j < attributes[i+3]; ++j) {
                    _result[_sum - _rest] = votes[i][j];
                    _rest -- ;
                }
            }
        }else {
            for(uint8 i = 0; i < attributes[0]; ++i) {
                for(uint8 j = 0; j < attributes[1]; ++j) {
                    _result[_sum - _rest] = votes[i][j];
                    _rest -- ;
                }
            }
        }
        return _result;
    }
        
    function callVotes(uint8 _i, uint8 _j) public returns(uint256){
        return votes[_i][_j];
    }   
        
    function () payable external {
        require(msg.sender == owner());    
    }
    
}