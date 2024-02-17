  // SPDX-License-Identifier: MIT
  pragma solidity ^0.8.9;

  import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
  import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
  import "@openzeppelin/contracts/access/Ownable.sol";

  contract SafeToken is ERC20Burnable, Ownable {
      constructor() ERC20("SafeToken", "STK") {
          // Mint initial supply to the contract owner
          _mint(msg.sender, 1000000 * 10**decimals());
      }

      // Function to mint additional tokens (only the owner can call this)
      function mint(address to, uint256 amount) external onlyOwner {
          _mint(to, amount);
      }

      // Function to transfer tokens with additional checks
      function safeTransfer(address to, uint256 amount) external {
          require(to != address(0), "Invalid transfer destination");
          require(amount > 0, "Invalid transfer amount");
          require(amount <= balanceOf(msg.sender), "Insufficient balance");

          _transfer(msg.sender, to, amount);
      }
  }
