// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4 <0.9.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Address.sol";

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
    ERC721("BiactroFounders", "BFOUNDER")
  {
    customBaseURI = customBaseURI_;

    proxyRegistryAddress = proxyRegistryAddress_;
  }

  /** MINTING **/

  uint256 public constant PRE_SALE_DATE = 1644796800; // Wednesday, 5 January 2022

  uint256 public constant MAX_MULTIMINT = 20;

  uint256 public constant MAX_PRE_SALE_SUPPLY = 900;

  uint256 public constant MAX_SUPPLY = 10000;

  uint256 public constant PRE_SALE_PRICE = 3000000000000000;

  uint256 public constant PRICE = 5200000000000000;

  uint256 public constant OWNER_MINT_LIMIT = 100;

  uint256 public OWNER_MINT_COUNTER = 0;

  function mint(uint256[] calldata ids) public payable nonReentrant {
    
    // Check if the sale is active
    require(saleIsActive, "Sale not active");
    
    uint256 count = ids.length;
    
    // Check if presale is active
    bool isPresale = (block.timestamp <= PRE_SALE_DATE) && preSaleIsActive;

    // Check if there`s enough tokens to mint
    require(totalSupply() + count - 1 < (isPresale ? MAX_PRE_SALE_SUPPLY : MAX_SUPPLY), "Exceeds max actual supply");

    // Check if the caller is the owner
    if (msg.sender != owner()) {
      // Check if the ether value is correct
      require(msg.value >= (isPresale ? PRE_SALE_PRICE * count : PRICE * count), "Insufficient actual payment value");
      
      // Check the user is not requiring an invalid token
      require(count <= MAX_MULTIMINT, "Max mint limit is 20");

      for (uint256 i = 0; i < count; i++) {
        uint256 id = ids[i];
        
        require(id < MAX_SUPPLY && id > 0, "Invalid token id");

        _safeMint(_msgSender(), id);
      }
    } else {
      // Check if the owner is not exceeding the limit
      require(OWNER_MINT_COUNTER < OWNER_MINT_LIMIT, "Owner mint limit exceeded");
      
      // Check if the owner is not requiring an invalid token
      require(count <= MAX_MULTIMINT, "Max mint limit is 20");

      // Check if the count is not exceedding the owner limit
      require(OWNER_MINT_COUNTER + count <= OWNER_MINT_LIMIT, "Owner mint limit exceeded"); 

      for (uint256 i = 0; i < count; i++) {
        uint256 id = ids[i];
        
        require(id < MAX_SUPPLY && id > 0, "Invalid token id");

        _safeMint(msg.sender, id);
        
        OWNER_MINT_COUNTER++;
      }
    }
  }

  /** ACTIVATION **/

  bool public saleIsActive = false;
  
  bool public preSaleIsActive = false;

  function setSaleIsActive(bool saleIsActive_) external onlyOwner {
    saleIsActive = saleIsActive_;
  }

  function setPreSaleIsActive(bool preSaleIsActive_) external onlyOwner {
    preSaleIsActive = preSaleIsActive_;
  }

  /** URI HANDLING **/

  string private customBaseURI;

  function _baseURI() internal view virtual override returns (string memory) {
    return customBaseURI;
  }

  /** PAYOUT **/

  address private constant developerPayoutAddress =
    0x7ea1Bb15c6D91827a37697c75b2Eeee930c0C188;

  function withdraw() public nonReentrant {
    uint256 balance = address(this).balance;

    Address.sendValue(payable(owner()), balance * 99 / 100);

    Address.sendValue(payable(developerPayoutAddress), balance * 1 / 100);
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

  /** Get wallet of owner **/
  function walletOfOwner(address _owner)
    public
    view
    returns (uint256[] memory)
  {
    uint256 ownerTokenCount = balanceOf(_owner);
    uint256[] memory ownedTokenIds = new uint256[](ownerTokenCount);
    uint256 currentTokenId = 1;
    uint256 ownedTokenIndex = 0;

    while (ownedTokenIndex < ownerTokenCount && currentTokenId <= MAX_SUPPLY) {
      address currentTokenOwner = ownerOf(currentTokenId);

      if (currentTokenOwner == _owner) {
        ownedTokenIds[ownedTokenIndex] = currentTokenId;

        ownedTokenIndex++;
      }

      currentTokenId++;
    }

    return ownedTokenIds;
  }
}