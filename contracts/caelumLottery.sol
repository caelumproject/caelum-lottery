pragma solidity ^0.4.24;

import "./libs/StandardToken.sol";

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

contract mockToken is StandardToken {
    string public symbol = "CLM";
    string public name = "Caelum Token";
    uint8 public decimals = 8;
    uint256 public totalSupply = 2100000000000000;

    constructor () {
        balances[msg.sender] = balances[msg.sender].add(100000 * 1e8);
    }
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

    bool winnersAnnounced;

    mapping (address => uint) public participantsList;

    address[] public participants;

    // Checks if still in lottery contribution period
    modifier lotteryOngoing() {
        require(now < lotteryStart + lotteryDuration);
        _;
    }

    // Checks if lottery has finished AND the total amount of participants
    // equals at least the mininmum required participants.
    modifier lotteryFinished() {
        require(now > lotteryStart + lotteryDuration);
        _;
    }

    modifier lotteryCompleted() {
        require(now > lotteryStart + lotteryDuration && participants.length >= lotteryMinParticipants, "Require failed");
        _;
    }

    uint public WINNER1;
    uint public WINNER2;
    uint public WINNER3;

    constructor () public {
        //participantsCounter = 0;
    }

    function () payable public {
        participateLottery();
    }

    function resetLottery (uint _days, uint _participants) onlyOwner lotteryFinished public {
        lotteryStart = now;
        lotteryDuration = _days * 1 days;
        lotteryMinParticipants = _participants;
        winnersAnnounced = false;
    }

    // Allow only 0.05 Ether deposits, one at a time.
    function participateLottery () payable lotteryOngoing public returns (bool success) {
        require(msg.value == 50 finney, "Wrong amount sent.");
        participantsList[msg.sender] = msg.value;
        participants.push(msg.sender);
        return true;
    }

    // Generally not safe to use the blockhash since this can be tampered by
    // miners. The cost to tamper this however is nowhere near the cost of mining
    // a full ethereum block, so there is no incentive to do this right now.
    // Leave this public so anyone can call the end of the lottery.
    //
    // This is just a quick and dirty solution, do not use this code on valuable items!

    function announceWinners () lotteryCompleted  public  returns (uint) {
        require (!winnersAnnounced, "Not completed");

        WINNER1 = random(1);
        WINNER2 = random(2);
        WINNER3 = random(3);

        winnersAnnounced = true;
    }

    function random(uint blocksPast) internal view returns (uint) {
        uint randomnumber = uint(blockhash(block.number - blocksPast)) % participants.length;
        return randomnumber;
    }

    function creditWinners () public {
        uint totalTokenAmount = ERC20Interface(token).balanceOf(this);

        uint amountWinner1 = totalTokenAmount / 100 * 50;
        uint amountWinner2 = totalTokenAmount / 100 * 30;
        uint amountWinner3 = totalTokenAmount / 100 * 20;

        totalTokenAmount = 0;

        if(!ERC20Interface(token).transfer(participants[WINNER1], amountWinner1)) revert();
        if(!ERC20Interface(token).transfer(participants[WINNER2], amountWinner2)) revert();
        if(!ERC20Interface(token).transfer(participants[WINNER3], amountWinner3)) revert();

    }


}
