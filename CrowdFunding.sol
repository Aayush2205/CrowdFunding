//SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract CrowdFunding is ERC20, AccessControl{
    bytes32 public constant MINTER_ROLE= keccak256("MINTER_ROLE");
    struct contributor{
        uint balance;
        address user;
        bool eligibility;
        uint time;
        bool rewardCollected;
    }

    address payable public owner;
    uint public deadline;
    uint public goal;
    uint public currentAmt;
    mapping(address=> contributor) public contribution;
    bool public isPaused;
    bool public goalReached;

    modifier notPaused(){
        require(!isPaused,"Contract is Paused");
        _;
    }
    modifier onlyOwner(){
        require(msg.sender== owner, "Not the owner");
        _;
    }
    modifier afterDeadline(){
        require(block.timestamp>= deadline," Campaign is still active");
        _;
    }

    event Contribution(address indexed contributor , uint value, uint timestamp);
    event ClaimReward(address indexed contributor, uint _reward, uint timestamp );
    event Withdrawal(address indexed contributor, uint value, uint timestamp);
    event TranferFund(address indexed owner, uint value, uint timestamp);

    constructor(uint _goal, uint _duration)ERC20("FundToken", "FDT"){
        owner = payable(msg.sender);
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        deadline= block.timestamp + _duration * 1 days;
        goal= _goal;
    }

    function remainingTime() public view returns (uint){
        return deadline -  block.timestamp;
    }

    function totalSupply() public view override returns(uint){
        return goal;
    }

    function deposit() public payable notPaused {
        currentAmt+= msg.value;

        if(currentAmt< goal) {
            contribution[msg.sender].user= msg.sender;
            contribution[msg.sender].balance+= msg.value;
            contribution[msg.sender].eligibility= true;
            contribution[msg.sender].time = block.timestamp;
        } 

        else if (currentAmt>=goal ){
            goalReached= true;
            isPaused= true;
            contribution[msg.sender].user= msg.sender;
            uint bal= (msg.value-(currentAmt-goal));
            contribution[msg.sender].balance+= bal;
            payable(msg.sender).transfer(msg.value-bal);
            currentAmt-=(msg.value-bal);
            contribution[msg.sender].eligibility= true;
            contribution[msg.sender].time = block.timestamp;
        }

        emit Contribution(msg.sender, msg.value, block.timestamp);

    }

    function rewardToPublic(address _to) public onlyRole(MINTER_ROLE){
        require(goalReached, "Goal Not Reached");
        require( contribution[_to].time< deadline,"No rewards after deadline");
        require(contribution[_to].eligibility,"Not Eligible");
        require(!contribution[_to].rewardCollected,"Reward already collected");
        uint balReward= ((contribution[_to].balance*10**decimals())/goal);
        _mint(_to, balReward);
        contribution[_to].eligibility= false;
        contribution[_to].rewardCollected = true;

        emit ClaimReward(_to ,balReward , block.timestamp);
    }

    function withdrawal() public afterDeadline{
        require(!goalReached,"Didn't reach the goal");
        if(contribution[msg.sender].eligibility == true){
            currentAmt-=contribution[msg.sender].balance;
            uint balWithdraw=contribution[msg.sender].balance;
            payable(msg.sender).transfer(balWithdraw);
            contribution[msg.sender].balance=0;
            contribution[msg.sender].eligibility= false;

            emit Withdrawal(msg.sender, balWithdraw, block.timestamp);
        }
    }

    function transferToAccount() public onlyOwner afterDeadline{
        require(goalReached,"Goal Not Reached");
        owner.transfer(address(this).balance);
        uint transBal= currentAmt;
        currentAmt=0;

        emit TranferFund(owner, transBal, block.timestamp);
    }

}
