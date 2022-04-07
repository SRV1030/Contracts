// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


contract DocumentManagementSystem {
    Resource[] public Resources;
    address public owner;
    uint minimumContribution;
    uint subscribersCount;
    mapping(address => bool) public subscribers;

    constructor(uint value){
        owner=msg.sender;
        minimumContribution=value;
    }

    
    modifier restricted() {
        require(msg.sender == owner, "manager privileges only");
        _;
    }

    function changeMinimumContribution(uint value) public restricted{
        minimumContribution=value;
    }
    function createResource(string memory key) public payable {
        require(address(this).balance>=minimumContribution,"Please pay minimum charge");
        Resource newResource = new Resource(msg.sender,key);
        Resources.push(newResource);
        payable(owner).transfer(address(this).balance);
    }

    function getResources() public view returns (Resource[] memory) {
        return Resources;
    }
}

contract Resource {
    struct file {        
        uint id;
        string description;
        uint256 minimumContribution;
        uint256 subscribersCount;
        uint timestamp;        
    }
    struct fileConfidential{
        string hash;
        mapping(address => bool) downloaders;
    }
    address public manager;
    string key;
    uint256 public employeeCount;
    uint256 public filesCount;
    uint256 fileIndex = 0;

    mapping(uint256 => fileConfidential) hashes;
    file[] public files;
    mapping(address => bool) public employees;

    
    constructor(address creator,string memory domainKey) {
        manager = creator;
        key=domainKey;
    }


    modifier restricted() {
        require(msg.sender == manager || employees[msg.sender], "manager privileges only");
        _;
    }

    modifier keyCheck(string memory val){        
        require(keccak256(abi.encodePacked((key))) == keccak256(abi.encodePacked((val))), "Verification key incorrect");
        _;
    }

    function changeKey(string memory value) public restricted{
       key=value;
    }
 
    function joinByKey(string memory value) public keyCheck(value){
       if(!employees[msg.sender]) {
           employees[msg.sender]=true;
           employeeCount++;
        }
    }
    
    function setEmployee(address emp) public restricted{
        if(!employees[msg.sender]){
            employeeCount++;
            employees[emp]=true;
        } 
    }

    function uploadfile(
        string memory description,
        string memory hash,
        uint256 value
    ) public restricted{        
        file memory newfile =  file(fileIndex,description,value,0,block.timestamp);
        files.push(newfile);
        fileConfidential storage h=hashes[fileIndex];
        h.hash=hash;
        fileIndex++;
        filesCount++;
    }
    function getAllFiles() public view returns (file[] memory){
        return  files;
    }

    function downloadFile(uint id) public view restricted returns(string memory) {        
        fileConfidential storage h= hashes[id];        
        return h.hash;
    }

    function getHeiDetails()
        public
        view
        returns (
            address,
            uint256,
            uint256
        )
    {   
        
        return (
            manager,
            filesCount,
            employeeCount
        );
    }

    function getfilesCount() public view returns (uint256) {
        return filesCount;
    }
}
