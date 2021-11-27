// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

contract BiactroWhiteList {
  
  uint memberCount;
  uint maxMembers = 100;
  string errorMessage;
  address owner;

  struct Member {
    address user;
    uint256 timestamp;
  }

  mapping(address => bool) public membersSigned;
  mapping(address => bool) public reserveSigned;

  Member[] membersList;
  Member[] reservationList;

  event newPreFounder(address wallet, uint256 timestamp);
  event newMemberInReservation(address wallet, uint256 timestamp);

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
      revert('Maximum number of members reached');
    }
    // Add the signer to the list
    membersList.push(Member(msg.sender, block.timestamp));
    membersSigned[msg.sender] = true;
    memberCount++;
    emit newPreFounder(msg.sender, block.timestamp);
  }

  // A function to add a member to the reservation list
  function addReservation() public {
    // Check if the signer is already in the members list
    if (membersSigned[msg.sender]) {
      revert('Address has already signed');
    }
    // Check if the signer is already in the reservation list
    if (reserveSigned[msg.sender]) {
      revert('Address already reserved');
    }
    // Add the signer to the list
    reservationList.push(Member(msg.sender, block.timestamp));
    reserveSigned[msg.sender] = true;
    emit newMemberInReservation(msg.sender, block.timestamp);
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
      revert('You can only extend the list');
    }
    // Set the new maximum number of members
    maxMembers = _maxMembers;
  }

  // A function to get all the members
  function getMembers() public view returns (Member[] memory) {
    return membersList;
  }

  // A funtion to get the max number of members
  function getMaxMembers() public view returns (uint) {
    return maxMembers;
  }

  // A function to get the number of members
  function getMemberCount() public view returns (uint) {
    return memberCount;
  }

  // A function to get if the address is in the list
  function isMember(address _address) public view returns (bool) {
    return membersSigned[_address];
  }

  // A function to get if the address is in the reservation list
  function isReservation(address _address) public view returns (bool) {
    return reserveSigned[_address];
  }

  // A function to get all the reservations
  function getReservations() public view returns (Member[] memory) {
    return reservationList;
  }
}