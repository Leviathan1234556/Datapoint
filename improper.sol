// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Vulnerability {
    address private USDC = 0x[REDACTED];
    mapping(address => uint256) public balances;
    uint256 public lotteryWinningNumber;
    address public owner;

    uint256 public ownershipThreshold = 51; // Set the ownership threshold

    constructor(){
        owner = msg.sender;
    }

    // Using strict equality is a vulnerability
    function fund_reached() public view returns (bool) {
        return address(this).balance == 100 ether;
    }

    // from field is dangerous to use in this case because if Person A has given allowance to this contract for some amount of tokens,
    // Person B can easily transfer those tokens to his own account
    function USDCTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) public {
        IERC20(USDC).transferFrom(_from, _to, _amount);
    }

    // anyone can kill the contract and claim any funds to their own address
    function kill() public {
        selfdestruct(payable(msg.sender));
    }

    // Using delegate should only be done on trusted contracts. so _to address should not be given here
    function delegate(address _to, bytes memory _data) public {
        (bool result, ) = _to.delegatecall(_data);
    }

    // Reentrancy attack. Balances variable is being updated after transfer here.
    function withdraw(uint256 _amount) public {
        if (balances[msg.sender] >= _amount) {
            (bool result, ) = msg.sender.call{value: _amount}("");
            require(result, "Could not transfer");
            balances[msg.sender] -= _amount;
        }
    }

    // Using of Block.timestamp, blockhash and now in random number generation is highly discouraged
    // Use of Chainlink VRF is preferred.
    function winLottery() external {
        lotteryWinningNumber = uint256(block.timestamp) % 10;
    }

    uint256 amt;
    // Dividing first can cause serious problems if b is greater than a.
    // So always multiply first and then divide
    function divideBeforeMultiply(uint256 a, uint256 b, uint256 c) public {
        amt = (a / b) * c;
    }

    // Avoid usage of Tx.origin
    function txOriginExploit(uint256 _amount) public {
        require(tx.origin == owner);
        withdraw(_amount);
    }

    // Since to is not initialized. It will be 0x0 address. and all money will be lost
    function transferMoney() payable public {
        address to;
        (bool result, ) = to.call{value: address(this).balance}("");
        require(result, "Could not transfer");
    }

    // The below shows the incorrect usage of storage and memory variables
    uint[1] public x; // storage

    function f() public {
        f1(x); // update x
        f2(x); // do not update x
    }

    function f1(uint[1] storage arr) internal { // by reference
        arr[0] = 1;
    }

    function f2(uint[1] memory arr) internal pure { // by value
        arr[0] = 2;
    }

    // Ownership check for 51%
    function checkOwnership(address _address) external view returns (bool) {
        uint256 totalSupply = IERC20(USDC).totalSupply();
        uint256 balance = IERC20(USDC).balanceOf(_address);

        return (balance * 100 / totalSupply >= ownershipThreshold);
    }
}
