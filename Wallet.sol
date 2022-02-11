// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol';
import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol';
contract Allowance is Ownable{

    using SafeMath for uint;

    event AllowanceChanged(address indexed _forwho,address indexed _fromWhom,uint _oldAmount, uint _newAmount);

    mapping(address=>uint) public allowance;
    function addAllowance(address _who,uint _amount) public onlyOwner{
        emit AllowanceChanged(_who,msg.sender,allowance[_who],_amount);
        allowance[_who]=_amount;
    }    
    function isOwner() public view returns(bool){
        return owner()==msg.sender;
    }  
    modifier ownerOrAllowed(uint _amount){
        require(isOwner() || allowance[msg.sender]>=_amount,"No access");
        _;
    } 
    function reduceAllowance(address _who,uint amount) internal{
        emit AllowanceChanged(_who,msg.sender,allowance[_who],allowance[_who].sub(amount));
        allowance[_who]=allowance[_who].sub(amount);
        
    }
} 
contract  Wallet is Allowance{  
    event MoneySent(address indexed _beneficiary, uint _amount);
    event MoneyReceived(address indexed _from, uint _amount);

    function withdrawMoney(address payable _to,uint _amount) public ownerOrAllowed(_amount){
        require(address(this).balance<_amount,"Not emough balance");        
        if(!isOwner()) {
            reduceAllowance(_to,_amount);
        }
        emit MoneySent(_to,_amount);
        _to.transfer(_amount);
    }
    function reciveMoney() public payable{
       emit MoneyReceived(msg.sender,msg.value);
    }
    function renounceOwnership() override pure public{
        revert("Can't renonunce");
    }
    fallback() external payable {
        // custom function code
        reciveMoney();
    }

    receive() external payable {
        // custom function code
        reciveMoney();
    }
}
