// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Adicoin is IERC20 {
    string private _name;
    string private _symbol;
    address private _owner;
    mapping(address => uint256) private _balances;
    uint256 private _totalSupply = 0;

    mapping(address => mapping(address => uint256)) private _allowances;

    event TokensBurned(address indexed from, uint256 value);
    event TokensMinted(address indexed to, uint256 value);

    constructor(string memory name, string memory symbol) {
        _name = name;
        _symbol = symbol;
        _owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Only the contract owner can perform this operation");
        _;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        require(recipient != address(0), "Invalid recipient address");
        address sender = msg.sender;
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "Insufficient balance");

        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function burn(uint256 amount) external returns (bool) {
        address sender = msg.sender;
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "Insufficient balance");

        _balances[sender] -= amount;
        _totalSupply -= amount;
        emit TokensBurned(sender, amount);
        return true;
    }

    function mint(address to, uint256 amount) external onlyOwner returns (bool) {
        require(to != address(0), "Invalid recipient address");
        _balances[to] += amount;
        _totalSupply += amount;
        emit TokensMinted(to, amount);
        return true;
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        address owner = msg.sender;
        uint256 ownerBalance = _balances[owner];
        require(spender != address(0), "Invalid spender address");
        require(ownerBalance >= amount, "Insufficient balance");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        require(recipient != address(0), "Invalid recipient address");
        uint256 allowanceAmount =  _allowances[sender][msg.sender];
        require(allowanceAmount >= amount, "Insufficient allowance");

        _balances[sender] -= amount;
        _balances[recipient] += amount;
        _allowances[sender][msg.sender] -= amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    error InvalidRecipient(address _recipient);
    error InsufficientBalance(address account, uint256 balance, uint256 amount);
    error InsufficientAllowance(address spender, address account, uint256 allowance, uint256 amount);
}
