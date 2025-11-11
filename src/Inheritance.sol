// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract Inheritance is Ownable {
    error ZeroAddressNotAllowedForHeir();
    error CannotBeOwnHeir();
    error EmptyHeir();
    error SameHeir();
    error InsufficientAmountInInheritance();
    error WithdrawFailed();
    error CallerCanOnlyBeHeir();
    error MonthTimeNotElapsedYet();
    error RejectUnknownExternalPayment();

    event InheritanceCreated(address indexed owner, address indexed heir, uint256 amount);
    event InheritanceIncreased(address indexed owner, uint256 amount, uint256 newTotal);
    event HeirUpdated(address indexed owner, address indexed oldHeir, address indexed newHeir);
    event WithdrawalMade(address indexed owner, uint256 previousAmount, uint256 remainingAmount);
    event TakeOverAfterAMonth(address indexed oldOwner, address indexed newOwner, address indexed newHeir);

    uint256 public inheritanceAmount;
    address public heir;
    uint256 public lastInteractedAt;

    constructor(address _heir) Ownable(msg.sender) payable {
        if(_heir == address(0)) revert ZeroAddressNotAllowedForHeir();
        if(msg.sender == _heir) revert CannotBeOwnHeir();
        inheritanceAmount = msg.value;
        heir = _heir;
        lastInteractedAt = block.timestamp;
        emit InheritanceCreated(msg.sender, heir, msg.value);
    }

    function increaseInheritance() public payable onlyOwner {
        inheritanceAmount += msg.value;
        lastInteractedAt = block.timestamp;
        emit InheritanceIncreased(msg.sender, msg.value, inheritanceAmount);
    }

    function updateHeir(address _newHeir) public onlyOwner {
        if(_newHeir == address(0)) revert EmptyHeir();
        if(_newHeir == heir) revert SameHeir();
        if(_newHeir == owner()) revert CannotBeOwnHeir();
        address previousHeir = heir;
        heir = _newHeir;
        lastInteractedAt = block.timestamp;
        emit HeirUpdated(msg.sender, previousHeir, heir);
    }

    function withdrawAndResetCounter(uint256 _amount) public onlyOwner {
        if(inheritanceAmount < _amount) revert InsufficientAmountInInheritance();
        lastInteractedAt = block.timestamp;
        uint256 prevAmount = inheritanceAmount;
        inheritanceAmount -= _amount;
        (bool success, ) = (msg.sender).call{value: _amount}("");
        if(!success) revert WithdrawFailed();
        emit WithdrawalMade(msg.sender, prevAmount, inheritanceAmount);
    }

    function takeOverAfterAMonth(address _newHeir) public {
        if(msg.sender != heir) revert CallerCanOnlyBeHeir();
        if(_newHeir == address(0)) revert EmptyHeir();
        if(msg.sender == _newHeir) revert CannotBeOwnHeir();
        address prevOwner = owner();
        uint256 monthDuration = 30 days;
        uint256 elapsed = block.timestamp - lastInteractedAt;
        if(elapsed < monthDuration) revert MonthTimeNotElapsedYet();
        _transferOwnership(heir);
        heir = _newHeir;
        lastInteractedAt = block.timestamp;
        emit TakeOverAfterAMonth(prevOwner, owner(), heir);
    }

    function getRemainingTimeUntilClaim() public view returns (uint256) {
        uint256 monthDuration = 30 days;
        uint256 elapsed = block.timestamp - lastInteractedAt;
        if (elapsed >= monthDuration) {
            return 0;
        }
        return monthDuration - elapsed;
    }

    receive() external payable {
        revert RejectUnknownExternalPayment();
    }
}

