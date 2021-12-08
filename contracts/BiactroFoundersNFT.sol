// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4 <0.9.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "hardhat/console.sol";

contract OwnableDelegateProxy {}

contract ProxyRegistry {
  mapping(address => OwnableDelegateProxy) public proxies;
}

contract BiactroFoundersNFT is
ERC721,
ERC721Enumerable,
IERC2981,
ReentrancyGuard,
Ownable
{
  using Counters for Counters.Counter;

  constructor (string memory customBaseURI_, address proxyRegistryAddress_)
    ERC721("BiactroFoundersNFT", "BFNFT")
  {
    customBaseURI = customBaseURI_;

    proxyRegistryAddress = proxyRegistryAddress_;
  }

  /** MINTING **/

  uint256 public constant PRE_SALE_DATE = 1641340800; // Wednesday, 5 January 2022

  uint256 public constant MAX_PRE_SALE_SUPPLY = 900;

  uint256 public constant MAX_SUPPLY = 10000;

  uint256 public constant PRE_SALE_PRICE = 15000000000000000;

  uint256 public constant PRICE = 60000000000000000;

  function mint(uint256 id) public payable nonReentrant {
    // Check if the sale is active
    require(saleIsActive, "Sale not active");
    
    // Check if presale is active
    bool isPresale = (PRE_SALE_DATE <= block.timestamp) && preSaleIsActive;

    // Check if there`s enough tokens to mint
    require(totalSupply() < (isPresale ? MAX_PRE_SALE_SUPPLY : MAX_SUPPLY), "Exceeds max actual supply");

    // Check if the value is correct
    require(msg.value >= (isPresale ? PRE_SALE_PRICE : PRICE), "Insufficient actual payment value");

    // Check the user is not requiring an invalid token
    require(id < MAX_SUPPLY && id > 0, "Invalid token id");

    _safeMint(_msgSender(), id);
  }

  /** ACTIVATION **/

  bool public saleIsActive = true;
  
  bool public preSaleIsActive = true;

  function setSaleIsActive(bool saleIsActive_) external onlyOwner {
    saleIsActive = saleIsActive_;
  }

  function setPreSaleIsActive(bool preSaleIsActive_) external onlyOwner {
    preSaleIsActive = preSaleIsActive_;
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

  function withdraw() public nonReentrant {
    uint256 balance = address(this).balance;

    Address.sendValue(payable(owner()), balance * 99 / 100);

    Address.sendValue(payable(payoutAddress1), balance * 1 / 100);
  }

  /** ROYALTIES **/

  function royaltyInfo(uint256, uint256 salePrice) external view override
    returns (address receiver, uint256 royaltyAmount)
  {
    return (address(this), (salePrice * 500) / 10000);
  }

  function _beforeTokenTransfer(address from, address to, uint256 tokenId)
      internal
      override(ERC721, ERC721Enumerable)
  {
      super._beforeTokenTransfer(from, to, tokenId);
  }

  function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override(ERC721, ERC721Enumerable, IERC165)
    returns (bool)
  {
    return (
      interfaceId == type(IERC2981).interfaceId ||
      super.supportsInterface(interfaceId)
    );
  }

  /** PROXY REGISTRY **/

  address private immutable proxyRegistryAddress;

  function isApprovedForAll(address owner, address operator)
    override
    public
    view
    returns (bool)
  {
    ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);

    if (address(proxyRegistry.proxies(owner)) == operator) {
      return true;
    }

    return super.isApprovedForAll(owner, operator);
  }
}