// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DocumentManagement{
    string public name;
    address public manager;
    uint public totaldocs=0;

    constructor (string memory nameofDoc){
        name=nameofDoc;
        manager=msg.sender;
    }
    modifier restricted() {
        require(msg.sender == manager, "manager privileges only");
        _;
    }
    modifier dataExists(uint id) {
        require(id<=totaldocs, "Document does not exist");
        _;
    }

    modifier hasBalance(uint money) {
        require(money<=address(this).balance, "Not sufficient balance");
        _;
    }

    struct Document{
        uint id;
        string doc_url_hash;
        string description;
        uint minAmount;
        uint timestamp;
        address payable author;        
    }

    mapping(uint => Document) public Documents;

    function uploadDocument(string memory doc, string memory desc, uint minAmountWei) public restricted{
        Documents[totaldocs]=Document(totaldocs,doc,desc,minAmountWei,block.timestamp,payable(msg.sender));
        totaldocs++;
    }

    function editDocument(uint id,string memory doc, string memory desc, uint minAmountWei) public restricted dataExists(id){
        Documents[id]=Document(id,doc,desc,minAmountWei,block.timestamp,payable(msg.sender));
    }

    function getDocument(uint id) public payable dataExists(id) returns(uint,string memory,string memory,uint,address){
        require(msg.value >  Documents[id].minAmount,"minimum contribution required");
        Document storage t = Documents[id];
        t.author.transfer(t.minAmount);
        return(
            t.id,
            t.doc_url_hash,
            t.description,
            t.timestamp,
            t.author
        );                
    }
    function checkoutBalance(uint amount) public payable restricted hasBalance(amount){
        payable(manager).transfer(amount);        
    }
    function viewBalance() public view returns(uint){
        return address(this).balance;
    }

}

