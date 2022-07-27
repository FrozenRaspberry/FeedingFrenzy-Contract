// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./ERC721A.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract FISH is Ownable, ERC721A, ReentrancyGuard {
    constructor(
    ) ERC721A("FISH", "Feeding Frenzy", 10, 3333) {}

    // For marketing etc.
    function reserveMint(uint256 quantity) external onlyOwner {
        require(
            totalSupply() + quantity <= collectionSize,
            "too many already minted before dev mint"
        );
        uint256 numChunks = quantity / maxBatchSize;
        for (uint256 i = 0; i < numChunks; i++) {
            _safeMint(msg.sender, maxBatchSize);
        }
        if (quantity % maxBatchSize != 0){
            _safeMint(msg.sender, quantity % maxBatchSize);
        }
    }

    // metadata URI
    string private _baseTokenURI;

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function setBaseURI(string calldata baseURI) external onlyOwner {
        _baseTokenURI = baseURI;
    }

    function withdrawMoney() external onlyOwner nonReentrant {
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "Transfer failed.");
    }

    function setOwnersExplicit(uint256 quantity) external onlyOwner nonReentrant {
        _setOwnersExplicit(quantity);
    }

    function numberMinted(address owner) public view returns (uint256) {
        return _numberMinted(owner);
    }

    function getOwnershipData(uint256 tokenId)
    external
    view
    returns (TokenOwnership memory)
    {
        return ownershipOf(tokenId);
    }

    //PUBLIC SALE
    /////////////////TEST
    bool public publicSaleStatus = true;
    uint256 public publicPrice = 0.003000 ether;
    uint256 public amountForPublicSale = 3333;
    // per mint public sale limitation
    uint256 public immutable publicSalePerMint = 10;

    function publicSaleMint(uint256 quantity) external payable {
        require(
        publicSaleStatus,
        "public sale has not begun yet"
        );
        require(
        totalSupply() + quantity <= collectionSize,
        "reached max supply"
        );
        require(
        amountForPublicSale >= quantity,
        "reached public sale max amount"
        );

        require(
        quantity <= publicSalePerMint,
        "reached public sale per mint max amount"
        );

        
        if (numberMinted(msg.sender) > 0) { // already minted
            require(
            uint256(publicPrice) * quantity <= msg.value,
            "Need more ETH, only 1 free for each wallet"
            );
        } else if (numberMinted(msg.sender) == 0 && quantity > 1) { // never minted and mint more than 1
            require(
            uint256(publicPrice) * (quantity - 1) <= msg.value,
            "Need more ETH, only 1 free for each wallet"
            );
        }

        _safeMint(msg.sender, quantity);
        amountForPublicSale -= quantity;
    }

    function setPublicSaleStatus(bool status) external onlyOwner {
        publicSaleStatus = status;
    }

    function getPublicSaleStatus() external view returns(bool) {
        return publicSaleStatus;
    }

}