//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFT is ERC721URIStorage {

    // auto-increment field for each token
    /// @dev auto-increment field
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // address of the NFT marketplace 
    address contractAddress; 

    constructor(address marketplaceAddress) ERC721("Metaverse Tokens", "TVT") {
        contractAddress = marketplaceAddress;    
    }

    /// @notice create a new token 
    /// @param tokenURI : token URI
    function createToken(string memory tokenURI) public returns(uint) {
        // set a new item id for the token to be minted
        _tokenIds.increment();
        uint newItemId = _tokenIds.current();

        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenURI);
        setApprovalForAll(contractAddress, true);

        return newItemId;

    }
}