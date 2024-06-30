// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MPAA is  ERC20, ERC20Permit, Ownable {
    uint256 public  tax_rate = 5; // 5% tax
    uint256 public constant MAX_SUPPLY =  177674000000 ether;
    mapping(address => bool) public isWhitelisted;
    
    constructor() ERC20("MPAA", "MPAA") ERC20Permit("MPAA") Ownable(msg.sender) {
        _mint(msg.sender, MAX_SUPPLY);
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
            uint256 taxAmount = (amount * tax_rate) / 100;
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
