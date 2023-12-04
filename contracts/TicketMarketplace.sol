// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.20;

import "./Ticket.sol";
import "./TicketMaster.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract TicketMarketplace is IERC721Receiver {
    TicketMaster public TicketMasterContract; 
    
    mapping (uint => mapping (uint256 => uint256)) listedTicketMapping; // cat->id->price (if price = 0, means delisted) 
    uint256 upperBoundRatio; // given as percentage. 100 means can resell at maximum of 100% original price. 
    bool allowReselling; // if resell is allowed, set to True

    constructor(address _TicketMasterContract, uint256 _upperBoundRatio, bool _allowReselling) {
        TicketMasterContract = TicketMaster(_TicketMasterContract);  
        upperBoundRatio = _upperBoundRatio; 
        allowReselling = _allowReselling; 
    }

    // check for FAIR ticket pricing
    modifier priceSufficient(uint256 askingPrice, uint256 categoryNr, uint256 ticketId) {
        Ticket ticketContract = TicketMasterContract.getSpecificTicketAddress(categoryNr);
        require(askingPrice <= (ticketContract.getOriginalTicketPrice()*upperBoundRatio)/100, "Reselling above price ceiling is not allowed");
        _;
    }

    // check if reselling is allowed 
    modifier checkResellAllowed() {
        require(allowReselling, "Reselling is not allowed");
        _;
    }    

    // check for ownership of a ticket
    modifier ownerOnly(uint256 categoryNr, uint256 ticketId) {
        Ticket ticketContract = TicketMasterContract.getSpecificTicketAddress(categoryNr);
        require(msg.sender == ticketContract.getOwnerOf(ticketId), "Only the owner of this ticketId can perform the function"); 
        _;
    }

    // check for prev ownership of a ticket (specifically for delisting) 
    modifier prevOwnerOnly(uint256 categoryNr, uint256 ticketId) {
        Ticket ticketContract = TicketMasterContract.getSpecificTicketAddress(categoryNr);
        require(msg.sender == ticketContract.getPrevOwner(ticketId), "Only the previous owner of this ticketId can perform the function"); 
        _;
    }

    // check if ticket is listed 
    modifier ticketIsListed(uint256 categoryNr, uint256 ticketId) {
        Ticket ticketContract = TicketMasterContract.getSpecificTicketAddress(categoryNr);
        require(address(this) == ticketContract.getOwnerOf(ticketId), "This ticket is currently not listed on the Marketplace"); 
        _;     
    }

    // List Ticket 
    function listTicket(uint256 askingPrice, uint256 categoryNr, uint256 ticketId) public checkResellAllowed() priceSufficient(askingPrice, categoryNr, ticketId) ownerOnly(categoryNr, ticketId) {
        Ticket ticketContract = TicketMasterContract.getSpecificTicketAddress(categoryNr);
        listedTicketMapping[categoryNr][ticketId] = askingPrice; // set the ticket asking price for the marketplace
        ticketContract.transferTicket(msg.sender, address(this), ticketId); // transfer ticket ownership to marketplace 
    }

    // Delist Ticket 
    function delistTicket(uint256 categoryNr, uint256 ticketId) public prevOwnerOnly(categoryNr, ticketId) ticketIsListed(categoryNr, ticketId) {
        Ticket ticketContract = TicketMasterContract.getSpecificTicketAddress(categoryNr);
        listedTicketMapping[categoryNr][ticketId] = 0; // set price to 0 to signify delisted 
        ticketContract.transferTicket(address(this), msg.sender, ticketId); // transfer ticket ownership back to prev owner 
    }

    // Get Specified Ticket's Price 
    // To get the lowest ticketprice, we will for loop outside the smart contract over all the ticketids to 
    // find the cheapest ticket for a specific cat 
    function getTicketPrice(uint256 categoryNr, uint256 ticketId) public view returns(uint256) {
        return listedTicketMapping[categoryNr][ticketId];
    }

    // Buy Ticket 
    function buyTicket(uint256 categoryNr, uint256 ticketId) public payable ticketIsListed(categoryNr, ticketId) {
        uint256 ticketPrice = getTicketPrice(categoryNr, ticketId);
        require(msg.value >= ticketPrice, "Insufficient ETH to purchase ticket"); 
        Ticket ticketContract = TicketMasterContract.getSpecificTicketAddress(categoryNr);
        address payable prevOwner = payable(ticketContract.getPrevOwner(ticketId)); 
        require(msg.sender != prevOwner, "Cannot buy back the ticket you've listed"); // Shouldnt be buy back, should just delist
        prevOwner.transfer(ticketPrice);
        payable(msg.sender).transfer(msg.value - ticketPrice); // Return the excess Ether if too much was provided 
        ticketContract.transferTicket(address(this), msg.sender, ticketId); // transfer ticket ownership from marketplace to purchasing party         
    }

    // Placeholder function to implement to ensure smart contract can receive NFT tokens 
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes memory _data) external returns(bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
    
}
