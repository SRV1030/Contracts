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

    function avilable_bgp_location(User[] memory users,string memory location) public view returns(string[100] memory){
        string[100] memory bgps;
        uint ind=0; 
        for(uint i=0;i<users.length;++i){
            if(compare(location,users[i].location()))bgps[ind++]=users[i].bloodgroup();
        }
        return bgps;
    }
    function check_user_eligibility(User[] memory users,uint id) public view returns(bool){        
        return users[id].date_of_donation()<= 6*2629800000;
    }
    function check_blood_expiry(User[] memory users,uint id) public view returns(bool){        
        return users[id].date_of_donation()<= 42*86400000;        
    }
}

contract MedHub {
    User[] public Users;    
    SMPC smpc= new SMPC();

    modifier validIndex(uint id) {
        require(id<Users.length, "manager privileges only");
        _;
    }

    function create_user(uint256 minimum,uint age,address payable user_address,string memory location,string memory blood_group) public returns(uint){
        User newResource = new User(minimum, user_address,age,location,blood_group);
        Users.push(newResource);
        return newResource.age();
    }

    function update_user(uint sugar,uint lower_bp,uint higher_bp,uint id,bool hiv) public  validIndex(id) returns (User){
        User c=Users[id];
        c.userUpdate(sugar, lower_bp, higher_bp,hiv );
        return c;
    }
    function update_user_blood_donation_date(uint id) public  validIndex(id) returns (User){
        User c=Users[id];
        uint tsp=block.timestamp;
        c.set_donation_time(tsp);
        return c;
    }
    function get_users() public view returns (User[] memory){
        return Users;
    }

    function smpc_call_above_eighteen() public view returns(int) {
        return smpc.getCountUseraboveEighteen(Users);
    }
    
    function smpc_get_count_of_normal_sugar_level_recepient() public view returns(int){
        return smpc.getNormalSugarLevel(Users);
    }

    function smpc_check_if_has_HIV(uint id) public view returns(bool){        
        return Users[id].hiv();
    }

    function smpc_total_number_of_hiv_patients() public view returns(int){
        return smpc.totalAmounHivPatients(Users);
    }

    function smpc_total_hiv_patient_location(string memory location) public view returns(int){
        return smpc.totalAmounHivPatientsAtLoctaion(Users, location);
    }
    function smpc_avilable_bgp_location(string memory location) public view returns(string[100] memory){
        return smpc.avilable_bgp_location(Users, location);
    }
    function smpc_check_user_eligibility(uint id) public view returns(bool){        
        return smpc.check_user_eligibility(Users, id);
    }
    function  smpc_check_blood_expiry(uint id) public view returns(bool){        
        return smpc.check_blood_expiry(Users, id);        
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
    uint public date_of_donation;
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
    
    function set_donation_time(uint tsmp) public restricted{
        date_of_donation =tsmp;
    }
}

