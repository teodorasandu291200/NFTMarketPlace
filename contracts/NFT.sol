//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./Auction.sol";

contract NFT is ERC721URIStorage {

    event AuctionCreated (
        address indexed auctionAddress
    );

    address auctionAddress = address(0);

    function getAuctionAddress() public view returns (address) {
    return auctionAddress;
}


    //auto-increment field for each token
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;

    //address of the NFT market place
    //https://t.me/techjobsng

    address contractAddress;

    constructor(address marketplaceAddress) ERC721("Partnerverse Tokens", "PNVT"){
       contractAddress = marketplaceAddress;
    }

    /// @notice create a new token
    /// @param tokenURI : token URI
    function createToken(string memory tokenURI) public returns(uint) {
        //set a new token id for the token to be minted
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();

        _mint(msg.sender, newItemId); //mint the token
        _setTokenURI(newItemId, tokenURI); //generate the URI
        setApprovalForAll(contractAddress, true); //grant transaction permission to marketplace
        auctionAddress = deployAuction();

        //return token ID
        return newItemId;

    }

    function deployAuction() public payable returns (address auction) {
    address newAuction = address(new Auction(250, payable(msg.sender)));
    emit AuctionCreated (
        newAuction
    );

    return newAuction;


  }
}
