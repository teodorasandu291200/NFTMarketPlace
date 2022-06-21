//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract NFTMarket is ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _itemIds;
    Counters.Counter private _itemsSold;

    address payable owner;
    uint listingPrice = 0.025 ether;

    constructor() {
        owner = payable(msg.sender);       
    }

    struct MarketItem {
        uint itemId;
        address nftContract;
        uint tokenId;
        address payable seller;
        address payable owner;
        uint price;
        bool sold;

    }
    

    mapping(uint => MarketItem) private idMarketItem;

    event MarketItemCreated (
        uint indexed itemId,
        address indexed nftContract,
        uint indexed tokenId,
        address seller,
        address owner,
        uint price,
        bool sold
    );

    function getListingPrice() public view returns (uint) {
        return listingPrice;
    }

    function setListingPrice(uint _price) public returns (uint) {
        if(msg.sender == address(this)) {
            listingPrice = _price;
        }
        return listingPrice;
    }

    /// @notice function to create market item
    function createMarketItem(address nftContract, uint256 tokenId, uint256 price) public payable nonReentrant {

        require(price > 0, "Price cannot be 0");
        require(msg.value == listingPrice, "Price must be equal to listing price");
        
        _itemIds.increment();
        uint256 itemId = _itemIds.current();


        // create new NFT
        idMarketItem[itemId] = MarketItem(
            itemId, 
            nftContract, 
            tokenId, 
            payable(msg.sender), 
            payable(address(0)), 
            price, 
            false
        );

        // transfer ownership of the NFT to the contract itself
        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

        emit MarketItemCreated(itemId, 
            nftContract, 
            tokenId, 
            msg.sender,
            address(0), 
            price, 
            false
        );
    }


        /// @notice function to create a sale
        function createMarketSale(
            address nftContract, 
            uint256 itemId) public payable nonReentrant {

                uint price = idMarketItem[itemId].price;
                uint tokenId = idMarketItem[itemId].tokenId;

                require(msg.value == price, "Please submit the asking price to complete purchase");
                // pay the seller the ammount
                idMarketItem[itemId].seller.transfer(msg.value);

                // transfer ownership of the NFT from the contract itself to the buyer
                IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);

                idMarketItem[itemId].owner = payable(msg.sender); // mark new buyer as new owner
                idMarketItem[itemId].sold = true; // mark that it has been sold
                _itemsSold.increment(); // increment the total number of items sold by 1
                payable(owner).transfer(listingPrice); // pay owner of contract the listing price

        }


        /// @notice total number of items unsold on our platform
        function fetchMarketItems() public view returns (MarketItem[] memory) {
            uint itemCount = _itemIds.current(); 
            uint unsoldItemCount = _itemIds.current() - _itemsSold.current();
            uint currentIndex = 0;

            MarketItem[] memory items = new MarketItem[](unsoldItemCount);

            // lopp through all items ever created 
            for(uint i = 0; i < itemCount; i++) {
                // check if the item has not been sold
                if(idMarketItem[i+1].owner == address(0)) {
                    uint currentId = idMarketItem[i + 1].itemId;
                    MarketItem storage currentItem = idMarketItem[currentId];
                    items[currentIndex] = currentItem;
                    currentIndex += 1;
                }
            }

            return items;
        }


        /// @notice fetch list of NFTs owned by this user
        function fetchMyNFTs() public view returns (MarketItem[] memory) {

            uint totalItemCount = _itemIds.current();

            uint itemCount = 0;
            uint currentIndex = 0;
            
            // get only the items that this user has
            for(uint i = 0; i < totalItemCount; i++) {
                if(idMarketItem[i+1].owner == msg.sender) {
                    itemCount += 1;
                }
            }

            MarketItem[] memory items = new MarketItem[](itemCount);
            for(uint i = 0; i < totalItemCount; i++) {
                if(idMarketItem[i+1].owner == msg.sender) {
                    uint currentId = idMarketItem[i+1].itemId;
                    MarketItem storage currentItem = idMarketItem[currentId];
                    items[currentIndex] = currentItem;
                    currentIndex += 1;
                }
            }

            return items;
        }




        function fetchItemsCreated() public view returns (MarketItem[] memory) {

            uint totalItemCount = _itemIds.current();

            uint itemCount = 0;
            uint currentIndex = 0;
            
            // get only the items that this user has
            for(uint i = 0; i < totalItemCount; i++) {
                if(idMarketItem[i+1].seller == msg.sender) {
                    itemCount += 1;
                }
            }

            MarketItem[] memory items = new MarketItem[](itemCount);
            for(uint i = 0; i < totalItemCount; i++) {
                if(idMarketItem[i+1].seller == msg.sender) {
                    uint currentId = idMarketItem[i+1].itemId;
                    MarketItem storage currentItem = idMarketItem[currentId];
                    items[currentIndex] = currentItem;
                    currentIndex += 1;
                }
            }
            return items;
        }


}
