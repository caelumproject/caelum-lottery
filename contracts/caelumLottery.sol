pragma solidity ^0.4.25;


contract Ownable {
  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() internal {
    _owner = msg.sender;
    emit OwnershipTransferred(address(0), _owner);
  }

  /**
   * @return the address of the owner.
   */
  function owner() public view returns(address) {
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
  function isOwner() public view returns(bool) {
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

contract ERC20Interface {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract CaelumLottery is Ownable {

    // What tokens will we send?
    address public token = 0;
    address public poolAddress = 0;

    // How many users are participating for the lottery
    uint public participantsCounter;

    uint public lotteryStart;
    uint public lotteryDuration;
    uint public lotteryMinParticipants;

    mapping (address => uint) public participantsList;

    address[] public participants;

    // Checks if still in lottery contribution period
    modifier lotteryOngoing() {
        require(now < lotteryStart + lotteryDuration);
        _;
    }

    // Checks if lottery has finished
    modifier lotteryFinished() {
        require(now > lotteryStart + lotteryDuration);
        _;
    }


    constructor (address _tokenForLottery, address _payoutAddress) public {
        token = _tokenForLottery;
        poolAddress = _payoutAddress;
    }

    function () payable public {
        participateLottery();
    }

    function resetLottery () public {

    }

    // Allow only 0.05 Ether deposits, one at a time.
    function participateLottery () lotteryOngoing public returns (bool success) {
        require(msg.value == 50 finney, "Wrong amount sent.")
        participantsList[msg.sender] = msg.value;
        participants.push(msg.sender);
    }

    // Generally not safe to use the blockhash since this can be tampered by
    // miners. The cost to tamper this however is nowhere near the cost of mining
    // a full ethereum block, so there is no incentive to do this right now.
    function announceWinners () public {

    }

    function creditWinners () public {
        if(!ERC20Interface(token).transfer(msg.sender, 50)) revert();
    }


}
