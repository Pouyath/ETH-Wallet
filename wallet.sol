// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";

contract Allowence is Ownable{

    using SafeMath for uint;
    event AllowenceChanged(address indexed _forWho, address indexed _fromWhom,uint _oldamount, uint _newAmount);
    address public _owner;
    mapping(address=> uint) public allowence;

    constructor () {
        _owner = msg.sender;
    }

    function reduceAllowence(address _who, uint _amount) internal{
        emit AllowenceChanged(_who, msg.sender, allowence[_who], allowence[_who] - _amount);
        allowence[_who] = allowence[_who].sub(_amount);
    }


    function addAllowence(address _who, uint _amount) internal{
        emit AllowenceChanged(_who, msg.sender, allowence[_who], _amount);
        allowence[_who] =_amount;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    modifier ownerOrAllowed(uint _amount){
        require(isOwner() || allowence[msg.sender] >= _amount, "you are not allowed");
        _;
    }

}


contract Wallet is Allowence{

    event MoneySent(address indexed _beneficiary, uint _amount);
    event MoneyReceived(address indexed _from, uint _amount);
    uint public cbalance;
    function getBalance() public{
        cbalance = address(this).balance;
    }

    function withdrawMoney(address payable _to, uint _amount) public ownerOrAllowed(_amount){
        require(address(this).balance >= _amount, "there are not enough funds stored in the smart contract");
        if (!isOwner()){
            reduceAllowence(msg.sender, _amount);
        }
        emit MoneySent(_to, _amount);
        _to.transfer(_amount);
    }

    function renounceOwnership() public override onlyOwner{
        revert("Can't renunce ownership here");
    }

    fallback () external payable{
        emit MoneyReceived(msg.sender, msg.value);
    }

}