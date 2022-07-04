//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Auction {

    address payable public beneficiary;
    uint public auctionEndTime;

    // Current state of the auction
    address public highestBidder;
    uint public highestBid;

    mapping( address => uint ) public pendingReturns;

    bool ended = false;

    event HighestBidIncrease(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);

      constructor(uint _biddingTime, address payable _beneficiary) {
        beneficiary = _beneficiary;
        auctionEndTime= block.timestamp + _biddingTime;
    }

    function bid( uint price) public payable {
        require(msg.sender != beneficiary, "Cannot bid on the same aucction you started");
        if ( block.timestamp > auctionEndTime ) {
            revert("The auction has ended");
        }

        if ( price <= highestBid) {
            revert("Higher bidder existent");
        }

        if ( highestBid != 0 ) {
            pendingReturns[highestBidder] += highestBid;
        }

        highestBidder = msg.sender;
        highestBid = price;
        emit HighestBidIncrease(msg.sender, price);
    }


    function withdraw() public returns (bool) {
        require(msg.sender != highestBidder && msg.sender != beneficiary, "Cannot withdraw, you have the highest bid");
        uint amount = pendingReturns[msg.sender];
        if ( amount > 0 ) {
            pendingReturns[msg.sender] = 0;

            if(!payable(msg.sender).send(amount)) {
                pendingReturns[msg.sender] = amount;
                return false;
            }
        }
        return true;
    }

    function auctionEnd() public {
        require(msg.sender == beneficiary, "Cannot end, you're not the beneficiary");
        if ( block.timestamp < auctionEndTime ) {
            revert("Auction not ended");
        }

        if (ended) {
            revert("auctionEnded already been called");
        }

        ended = true;
        emit AuctionEnded(highestBidder, highestBid);
    }

}
