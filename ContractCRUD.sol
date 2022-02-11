// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract  StartStopUpdateContract{
    address owner;
    bool public paused;
    constructor(){
        owner=msg.sender;
        paused=false;
    }

    modifier admin(){
        require(msg.sender==owner,"Only Admin can access");
        _;
    }
    modifier ispaused(){
        require(!paused,"Contract Paused");
        _;
    }
    function sendMoney() public payable ispaused {

    }

    function setPause(bool _paused) public admin{
        paused=_paused;
    }
    function withdrawAllMoney(address payable _to)public admin ispaused{
        _to.transfer(address(this).balance);
    }

    function destroySmartContract(address payable _to) public admin{
        selfdestruct(_to);
    }

}
