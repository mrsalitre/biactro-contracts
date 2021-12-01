// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract BiactroWhiteList is Ownable {
  
  bool reservationIsActive = true;
  uint memberCount;
  uint maxMembers = 900;
  string errorMessage;

  struct Member {
    address user;
    uint256 timestamp;
  }

  mapping(address => bool) membersSigned;
  mapping(address => uint) membersReservedTokens;
  mapping(uint => bool) asignedNumbers;

  Member[] membersList;

  event newPreFounder(address wallet, uint256 timestamp);

  constructor() {}

  // A function to save the address of the signer
  function addMember(uint _tokenID) public {
    require(reservationIsActive, "Reservation is closed");
    // Check if the signer is already in the list
    if (membersSigned[msg.sender]) {
      revert('Address has already signed');
    }
    if (_tokenID < 0 || _tokenID > 40900) {
      revert('Token ID is invalid');
    }
    if (asignedNumbers[_tokenID]) {
      revert('Token has already been taken');
    }
    // Check if the list is full
    if (memberCount >= maxMembers) {
      reservationIsActive = false;
      revert('List is full');
    }
    saveMember(_tokenID);
  }

  function saveMember(uint _tokenID) internal {
    
    // Add the signer to the list
    membersList.push(Member(msg.sender, block.timestamp));
    
    // Save the signer in the mapping
    membersSigned[msg.sender] = true;
    
    // Save the tokenID in reserved tokens mapping
    membersReservedTokens[msg.sender] = _tokenID;
    
    // Save the tokenID in asigned numbers mapping
    asignedNumbers[_tokenID] = true;
    
    // Increase the number of members
    memberCount++;

    emit newPreFounder(msg.sender, block.timestamp);
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
  
  function switchReservation(bool _opened) public onlyOwner {
    reservationIsActive = _opened;
  }
}