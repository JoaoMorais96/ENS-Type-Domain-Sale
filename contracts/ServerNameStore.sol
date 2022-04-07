// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ServerNameStore {
    //Saves all the names created
    mapping(string => bool) existingNames;
    //Maps the existing names to their owner address
    mapping(string => address) serverNameOwner;
    //Maps the existing names to their values
    mapping(string => string) serverNameValues;
    //Maps server names to the last payed price
    mapping(string => uint256) serverNamePrice;

    //Price to pay to the contract if the server has no previous owner
    uint256 public MinPrice;

    //Token Contract address placeholder
    IERC20 public STK;

    //locked == false
    bool internal locked;

    //Avoid reentrancy
    modifier noReentrency(){
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }

    constructor(uint256 _MinPrice, address STKAddress){
        //Establish a minimum price to pay for newly created dom names
        MinPrice = _MinPrice;
        //Get our token address
        STK = IERC20(STKAddress);
    }


    //Only the owners of the server can manipulate its value
    modifier ownerOfServerName(string memory _name){
        require(msg.sender == serverNameOwner[_name], 'Not the owner of this server name');
        _;
    }


    function buyDomain(string memory _name, uint256 _amount) external payable noReentrency(){
        if(existingNames[_name]==false){//If this domain name does not exist
            //Pay the min price
            STK.transferFrom(msg.sender, address(this), MinPrice);
            //Update the mappings
            existingNames[_name]=true;
            serverNameOwner[_name]=msg.sender;
            serverNameValues[_name]='';
            serverNamePrice[_name]=MinPrice;
            
        }else{//If the domain name already has an owner
            require(_amount > serverNamePrice[_name]);//Require that the price is bigger than the las payed price for this dom
            //Pays the owner
            STK.transferFrom(msg.sender, serverNameOwner[_name], _amount);
            //Update mappings
            serverNameOwner[_name]=msg.sender;
            serverNamePrice[_name]=_amount;
        }     
    }


    //Changes the value of the server
    function changeServerValue(string memory _name, string memory _newValue) public ownerOfServerName(_name){
        serverNameValues[_name]=_newValue;

    }
    //See the value of a specific domain name
    function queryValue(string memory _name) public view returns(string memory){
        return serverNameValues[_name];
    }
}