// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

contract BiactroWhiteList {
  
  uint memberCount;
  uint maxMembers;
  address owner;
  string errorMessage;

  struct Member {
    address user;
    uint256 timestamp;
  }

  mapping(address => bool) public membersSigned;
  Member[] membersList;

  constructor() {
    owner = msg.sender;
  }

  // A function to save the address of the signer
  function addMember() public {
    // Check if the signer is already in the list
    if (membersSigned[msg.sender]) {
      revert('Address has already signed');
    }
    // Check if the list is full
    if (memberCount >= maxMembers) {
      revert('maximum number of members reached');
    }
    // Add the signer to the list
    membersList.push(Member(msg.sender, block.timestamp));
    membersSigned[msg.sender] = true;
    memberCount++;
  }
  // A function to set the maximum number of members
  // This function can only be called by the owner of the contract
  function setMaxMembers(uint _maxMembers) public {
    // Check if the sender is the owner
    if (msg.sender != owner) {
      revert('Only the owner can set the maximum number of members');
    }
    // Check if the new maximum number of members is greater than the current number of members
    if (_maxMembers <= memberCount) {
    revert();
    }
    // Set the new maximum number of members
    maxMembers = _maxMembers;
  }

  // A function to get all the members
  function getMembers() public view returns (Member[] memory) {
    return membersList;
  }

  // A function to get the number of members
  function getMemberCount() public view returns (uint) {
    return memberCount;
  }

  // A function to get if the address is in the list
  function isMember(address _address) public view returns (bool) {
    return membersSigned[_address];
  }
}