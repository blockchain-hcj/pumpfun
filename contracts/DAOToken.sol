// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DAOToken is ERC20, Ownable {
    uint256 public constant TAX_RATE = 5; // 5% tax
    mapping(address => bool) public isWhitelisted;

    constructor(string memory name, string memory symbol, uint256 initialSupply) ERC20(name, symbol) Ownable(msg.sender) {
        _mint(msg.sender, initialSupply);
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        return _transferWithTax(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(sender, spender, amount);
        return _transferWithTax(sender, recipient, amount);
    }

    function _transferWithTax(address sender, address recipient, uint256 amount) internal returns (bool) {
        if (isWhitelisted[sender] || isWhitelisted[recipient]) {
            _transfer(sender, recipient, amount);
        } else {
            uint256 taxAmount = (amount * TAX_RATE) / 100;
            uint256 amountAfterTax = amount - taxAmount;
            _transfer(sender, owner(), taxAmount);
            _transfer(sender, recipient, amountAfterTax);
        }
        return true;
    }

    function addToWhitelist(address account) external onlyOwner {
        isWhitelisted[account] = true;
    }

    function removeFromWhitelist(address account) external onlyOwner {
        isWhitelisted[account] = false;
    }
}
