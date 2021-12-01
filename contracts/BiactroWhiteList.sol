// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract BiactroWhiteList is Ownable {
  
  bool reservationIsActive = true;
  uint memberCount;
  uint maxMembers = 900;

  struct Member {
    address user;
    uint256 tokenId;
    uint256 timestamp;
  }

  mapping(address => uint) membersSigned;
  mapping(uint => bool) asignedNumbers;

  Member[] membersList;

  event newPreFounder(address wallet, uint256 timestamp);

  constructor() {}

  // A function to save the address of the signer
  function addMember(uint _tokenID) public {
    
    // Check if reservation is active
    require(reservationIsActive, "Reservation is closed");
    
    // Check if the signer is already in the list
    require(!isMember(msg.sender), "You are already in the list");
    
    // Check if the selected token is on range
    if (_tokenID < 0 || _tokenID > 40950) {
      revert("Token ID is invalid");
    }

    // Check if the token has been taken
    require(isTokenAvailable(_tokenID), "Token is not available");
    
    // Check if the list is full
    if (memberCount >= maxMembers) {
      revert("List is full");
    }
    saveMember(_tokenID);
  }

  function saveMember(uint _tokenID) internal {
    
    // Add the signer to the list
    membersList.push(Member(msg.sender, _tokenID, block.timestamp));
    
    // Save the signer in the mapping
    membersSigned[msg.sender] = _tokenID;
    
    // Save the tokenID in asigned numbers mapping
    asignedNumbers[_tokenID] = true;
    
    // Increase the number of members
    memberCount++;

    if (memberCount >= maxMembers) {
      reservationIsActive = false;
    }

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
    if (membersSigned[_address] != 0) {
      return true;
    } else {
      return false;
    }
  }

  // A function to check if a token is available
  function isTokenAvailable(uint _tokenID) public view returns (bool) {
    return asignedNumbers[_tokenID];
  }

  // A function to know if the reservation is active
  function isReservationActive() public view returns (bool) {
    return reservationIsActive;
  }
  
  // A function to toggle the reservation
  function switchReservation(bool _opened) public onlyOwner {
    reservationIsActive = _opened;
  }

  // A function only callable by owner that saves id tokens inside the asignedNumbers mapping
  function saveToken(uint _tokenIDs) public onlyOwner {
    asignedNumbers[_tokenIDs] = true;
  }
}