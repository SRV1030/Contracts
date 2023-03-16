// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract SMPC{
    
    function compare(string memory str1, string memory str2) public pure returns (bool) {
        return keccak256(abi.encodePacked(str1)) == keccak256(abi.encodePacked(str2));
    }

    function getCountUseraboveEighteen(User[] memory users) public view returns(int){
        int c=0;
        for(uint i=0;i<users.length;++i){
            if(users[i].age()>=18)++c;
        }
        return c;
    }
    function getNormalSugarLevel(User[] memory users) public view returns(int){
        int c=0;
        for(uint i=0;i<users.length;++i){
            if(users[i].sugar()>=135 || users[i].sugar()<=145)++c;
        }
        return c;
    }

    function checkHiv(User[] memory users,uint id) public view returns(bool){        
        return users[id].hiv();
    }

    function totalAmounHivPatients(User[] memory users) public view returns(int){
        int c=0;
        for(uint i=0;i<users.length;++i){
            if(users[i].hiv())++c;
        }
        return c;
    }

    function totalAmounHivPatientsAtLoctaion(User[] memory users,string memory location) public view returns(int){
        int c=0;
        for(uint i=0;i<users.length;++i){
            if(compare(location,users[i].location()) && users[i].hiv())++c;
        }
        return c;
    }

}

contract MedHub {
    User[] public Users;    
    SMPC smpc= new SMPC();

    modifier validIndex(uint id) {
        require(id<Users.length, "manager privileges only");
        _;
    }

    function createUser(uint256 minimum,uint age,address payable userAddress,string memory location,string memory bgp) public returns(uint){
        User newResource = new User(minimum, userAddress,age,location,bgp);
        Users.push(newResource);
        return newResource.age();
    }

    function updateUser(uint sugar,uint lbp,uint hbp,uint id,bool hiv) public  validIndex(id) returns (User){
        User c=Users[id];
        c.userUpdate(sugar, lbp, hbp,hiv );
        return c;
    }
    function getUsers() public view returns (User[] memory){
        return Users;
    }
    function SMPCcallaboveeighteen() public view returns(int) {
        return smpc.getCountUseraboveEighteen(Users);
    }
}

contract User {
    address public manager;
    uint256 public minimumContribution;
    uint public age;
    string public location;
    string public  bloodgroup;
    uint public sugar;
    uint public lbp;
    uint public hbp;  
    bool public hiv=false;
    mapping ( address => bool) medicalOfficials; 

    
    constructor(uint256 minimum, address payable  creator,uint ageP,string memory locP,string memory bgp) payable {
        manager = creator;
        minimumContribution = minimum;
        age=ageP;
        bloodgroup=bgp;
        location=locP;
        medicalOfficials[msg.sender]=true;
    }

    modifier restricted() {
        require(msg.sender == manager || medicalOfficials[msg.sender], "manager or medical personnel privileges only");
        _;
    }

    function userUpdate(uint sg,uint lp,uint hp,bool hivP) public restricted{
        sugar=sg;
        lbp=lp;
        hbp=hp;
        hiv=hivP;
    }
    
}

