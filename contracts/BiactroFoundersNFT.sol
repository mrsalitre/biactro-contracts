// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4 <0.9.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract BiactroFoundersNFT is ERC721, IERC2981, ReentrancyGuard, Ownable {
  using Counters for Counters.Counter;

  constructor (string memory customBaseURI_) ERC721("Biactro Founders", "BFNFT")
  {
    customBaseURI = customBaseURI_;
  }

  /** MINTING **/

  uint256 public constant MAX_SUPPLY = 40000;

  uint256 public constant PRICE = 15000000000000000;

  Counters.Counter private supplyCounter;

  // TODO: to check if the id is not reserved in BiactroWhitelist
  function mint(uint256 id) public payable nonReentrant {
    require(saleIsActive, "Sale not active");

    require(totalSupply() < MAX_SUPPLY, "Exceeds max supply");

    require(msg.value >= PRICE, "Insufficient payment, 0.015 ETH per item");

    require(id < MAX_SUPPLY, "Invalid token id");

    _safeMint(_msgSender(), id);

    supplyCounter.increment();
  }

  // TODO: a function to mint the token a user has reserved.
  // once the wallet triggers the function, the token id saved in reservation list shoould change to 0.

  // TODO: a function to give away the NFT to a user.

  function totalSupply() public view returns (uint256) {
    return supplyCounter.current();
  }

  /** ACTIVATION **/

  bool public saleIsActive = false;

  function setSaleIsActive(bool saleIsActive_) external onlyOwner {
    saleIsActive = saleIsActive_;
  }

  /** URI HANDLING **/

  string private customBaseURI;

  function setBaseURI(string memory customBaseURI_) external onlyOwner {
    customBaseURI = customBaseURI_;
  }

  function _baseURI() internal view virtual override returns (string memory) {
    return customBaseURI;
  }

  /** PAYOUT **/

  address private constant payoutAddress1 =
    0x7ea1Bb15c6D91827a37697c75b2Eeee930c0C188;

  function withdraw() public {
    uint256 balance = address(this).balance;

    payable(owner()).transfer(balance * 99 / 100);

    payable(payoutAddress1).transfer(balance * 1 / 100);
  }

  /** ROYALTIES **/

  function royaltyInfo(uint256, uint256 salePrice) external view override
    returns (address receiver, uint256 royaltyAmount)
  {
    return (address(this), (salePrice * 500) / 10000);
  }
}