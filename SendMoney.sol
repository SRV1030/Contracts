// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract  SendMoney{
    uint public blanceReceived;

    function receiveMoney() public payable {
        blanceReceived+=msg.value;//msg refelects the transaction msg
    }
    function getBalance() public view returns(uint){
        return address(this).balance;
    }
    function withdrawMoney() public{
        address payable requester = payable(msg.sender);// address of the guy wanting to withdraw money or say one who accessed the contract
         blanceReceived=0;
        requester.transfer(this.getBalance());
    }
    function withdrawMoneyTo(address payable addr) public {
        blanceReceived=0;
        addr.transfer(this.getBalance());
    }
}
