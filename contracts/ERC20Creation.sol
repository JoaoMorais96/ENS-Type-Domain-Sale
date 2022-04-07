// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;



import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract ERC20Creation is ERC20, ERC20Burnable {

    //Maps admin addresses
    mapping(address => bool) admins;

    constructor(address[] memory _adminAddresses) ERC20('Server Token', 'STK') { 

        //Establish the admin addresses who can mint and burn tokens on demand
        for(uint i = 0; i < _adminAddresses.length; i ++){
            admins[_adminAddresses[i]]=true;
        }    
    }

    //Require msg.sender to be an admin
    modifier onlyAdmin(){
        require(admins[msg.sender] == true);
        _;
    }

    //Mint new tokens (only for admins)
    function mintTokens(uint256 _amount) public onlyAdmin {
        _mint(msg.sender,_amount*10**18);
    }

    //Burn tokens (only for admins)
    function burnTokens(uint256 _amount) public onlyAdmin {
        require(balanceOf(msg.sender)>=_amount, "Insufficient balance");
        burn(_amount*10**18);
    }

}