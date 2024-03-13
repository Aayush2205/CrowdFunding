# CrowdFunding

## Testnet Used -
~~~
BNB Smart Chain Testnet
~~~
## Contract Address-
~~~
0x539FAcAA4f382B4fC1Cab6f0B107a86aa177FcD0
~~~
## Block Explorer Link-
BscScan - [Live Preview](https://testnet.bscscan.com/tx/0x3417423ae0ff9d9398cbc3b5efdf3b5e21253aa7dd011b4c2b7b9356754ba6ad)

## Introduction-
Crowdfunding is a way to raise funds for a specific cause or project by asking a large number of people to donate money, usually in small amounts, and usually during a relatively short period of time, such as a few months. Crowdfunding is done online, often with social networks, which make it easy for supporters to share a cause or project cause with their social networks.

Organizations, businesses, and individuals alike can use crowdfunding for any type of project, for example: charitable cause; creative project; business startup; school tuition; or personal expenses.

## Code Related Info

### Funcions-

deposit() - Used by the contributor to contribute for the fund.
rewardToPublic() - Accessable only by the minter to mint tokens as a reward for the contributors who contributed before the deadline
withdrawal() - If the goal is not fulfilled before the deadline then the contributors have an option to withdraw their contributions
transferToAccount() - this is to tranfer the fund which is collected to the owner of the CrowdFund

### Modifiers

onlyOwner() - only the owner of the contracted can access
notPaused() - is used when we want to run a check on a function whether is it paused or not
afterDeadline()- will run a function only when the deadline has been reached

### Events

Contribution(address indexed contributor , uint value, uint timestamp)- Event for deposit
ClaimReward(address indexed contributor, uint _reward, uint timestamp)- Event for rewardToPublic
Withdrawal(address indexed contributor, uint value, uint timestamp)- Event for withdrawal
TranferFund(address indexed owner, uint value, uint timestamp)- Event for tranferToAccount
