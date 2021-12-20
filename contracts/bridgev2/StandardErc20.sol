// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract Role is AccessControl{
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

    constructor(){
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(MANAGER_ROLE, msg.sender);
    }

    modifier onlyManager(){
        require(hasRole(MANAGER_ROLE, msg.sender), "Caller is not a manager");
        _;
    }

    function addManager(address manager) external onlyRole(DEFAULT_ADMIN_ROLE){
        _setupRole(MANAGER_ROLE, manager);
    }
}

contract Token is ERC20, Role {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
    }

    function mint(address to, uint256 amount) external onlyManager {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external onlyManager {
        _burn(from, amount);
    }
}