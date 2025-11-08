// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract Inheritance is Ownable {
    error ZeroAmountNotAllowed();
    error ZeroAddressNotAllowedForHeir();
    error CannotBeOwnHeir();
    error MismatchAmount();
    error EmptyHeir();
    error SameHeir();
    error InsufficientAmountInInheritance();
    error WithdrawFailed();
    error CallerCanOnlyBeHeir();
    error MonthTimeNotElapsedYet();

    event InheritanceCreated(address indexed owner, address indexed heir, uint256 amount);
    event InheritanceIncreased(address indexed owner, uint256 amount, uint256 newTotal);
    event HeirUpdated(address indexed owner, address indexed oldHeir, address indexed newHeir);
    event WithdrawalMade(address indexed owner, uint256 previousAmount, uint256 remainingAmount);
    event TakeOverAfterAMonth(address indexed oldOwner, address indexed newOwner, address indexed newHeir);

    uint256 public inheritanceAmount;
    address public heir;
    uint256 public lastInteractedAt;

    constructor(address _heir, uint256 _inheritance_amount) Ownable(msg.sender) payable {
        if(_inheritance_amount == 0) revert ZeroAmountNotAllowed();
        if(_heir == address(0)) revert ZeroAddressNotAllowedForHeir();
        if(msg.sender == _heir) revert CannotBeOwnHeir();
        if(msg.value != _inheritance_amount) revert MismatchAmount();
        inheritanceAmount = _inheritance_amount;
        heir = _heir;
        lastInteractedAt = block.timestamp;
        emit InheritanceCreated(msg.sender, heir, _inheritance_amount);
    }

    function increaseInheritance(uint256 _increaseByAmount) public payable onlyOwner {
        if(_increaseByAmount == 0) revert ZeroAmountNotAllowed();
        if(msg.value != _increaseByAmount) revert MismatchAmount();
        inheritanceAmount += _increaseByAmount;
        lastInteractedAt = block.timestamp;
        emit InheritanceIncreased(msg.sender, _increaseByAmount, inheritanceAmount);
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
        transferOwnership(heir);
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
        revert("Direct transfers not allowed");
    }
}

/*
    Does the contract need to save inheritance for one user or multiple users in a single contract?
    Can the owner increase the inheritance amount after deploying the contract?
    Can people other than the owner increase the inheritance amount?
    Can the owner change the heir after it has been set?
    Can the original owner withdraw inheritance if 30 days are up but the heir has not yet claimed ownership? If yes, then will the interactedAt time be updated or will it remain expired? -- rn yes
*/
