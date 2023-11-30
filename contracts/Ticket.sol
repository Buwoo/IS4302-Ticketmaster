// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.20;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";

contract Ticket is ERC721 {
    // Information common to each ticket
    address payable eventOrganiser; 
    string eventName; 
    string eventSymbol; 
    uint256 currentMintedTicketId; 
    uint256 lastSoldTicketId; // This Id <= currentMintedTicketId
    uint256 totalTicketSupply; 
    uint256 category; 
    uint256 originalTicketPrice; // in wei 
    uint256 commissionFee; // in wei

    // Extra information unique to each ticket 
    struct TicketInfo {
        address originalTicketMinter; 
        address prevOwner; 
        uint256 currTicketPrice;
    }

    // Information for each id
    mapping (uint256 => TicketInfo) public tickets; 

    constructor(
        string memory _eventName, 
        string memory _eventSymbol, 
        uint256 _totalTicketSupply, 
        uint256 _category, 
        uint256 _originalTicketPrice, 
        uint256 _commissionFee) 
        ERC721(_eventName, _eventSymbol) {

        eventOrganiser = payable(msg.sender); 
        eventName = _eventName; 
        eventSymbol = _eventSymbol; 
        currentMintedTicketId = 0; 
        lastSoldTicketId = 0; 
        totalTicketSupply = _totalTicketSupply; 
        category = _category; 
        originalTicketPrice = _originalTicketPrice;
        commissionFee = _commissionFee; 
    }

    modifier onlyEventOrganiser() {
        require(msg.sender == eventOrganiser, "Only the Event Organiser can perform this action");
        _; 
    }

    // Getter Functions
    function getEventName() public view returns (string memory) {
        return eventName; 
    }

    function getEventSymbol() public view returns (string memory) {
        return eventSymbol; 
    }

    function getCategory() public view returns (uint256) {
        return category; 
    }

    function getOriginalTicketPrice() public view returns (uint256) {
        return originalTicketPrice; 
    }

    function getCommissionFee() public view returns (uint256) {
        return commissionFee; 
    }

    // to decide if we want to limit the usage of this function or make it public
    function getCurrentTicketPrice(uint256 ticketId) public view returns (uint256) {
        return tickets[ticketId].currTicketPrice;
    }

    // For checking ticket authenticity, the output address should be the ticketmaster address
    function checkOriginalMinter(uint256 ticketId) public view returns (address) {
        return tickets[ticketId].originalTicketMinter;
    }

    // to decide if we want to limit visibility, public for ease of testing sake rn 
    function getOwnerOf(uint256 ticketId) public view returns (address) {
        return ownerOf(ticketId);
    }

    function getPrevOwner(uint256 ticketId) public view returns (address) {
        return tickets[ticketId].prevOwner;
    }

    // change currentTicketPrice 
    function changeCurrentTicketPrice(uint256 ticketId, uint256 newTicketPrice) external {
        tickets[ticketId].currTicketPrice = newTicketPrice;
    }

    // // change prevOwner  
    // function changePrevOwner(uint256 ticketId, address updatePrevOwner) external {
    //     tickets[ticketId].prevOwner = updatePrevOwner;
    // }

    // Tickets start from ID = 1 
    // Main function to mint tickets 
    function mintTicket() onlyEventOrganiser public {
        currentMintedTicketId+=1;
        require(currentMintedTicketId <= totalTicketSupply, "Cannot mint more tickets, total supply reached"); 
        _mint(msg.sender, currentMintedTicketId);
        tickets[currentMintedTicketId] = TicketInfo({
            originalTicketMinter: msg.sender,
            prevOwner: address(0), 
            currTicketPrice: originalTicketPrice
        }); 
    }   

    // Allow for the bulk minting of tickets 
    function bulkMintTickets(uint256 _nrOfTickets) onlyEventOrganiser public {
        require(currentMintedTicketId + _nrOfTickets <= totalTicketSupply, "Cannot mint more tickets, total supply reached"); 
        for (uint i = 0; i < _nrOfTickets; i++) {
            mintTicket(); 
        }
    }

    function transferTicket(address from, address to, uint256 ticketId) external {
        require(ownerOf(ticketId) == from, "Not the ticket owner");

        // Transfer the ticket to the new owner
        _safeTransfer(from, to, ticketId);

        // Update previous owner
        tickets[ticketId].prevOwner = from;
    }

    // Purchase ticket from the event organiser (official purchasing means)
    function buyTicket(address given_address) public payable {
        uint256 totalTicketPrice = originalTicketPrice + commissionFee; 
        require(msg.value >= totalTicketPrice, "Insufficient ETH to purchase ticket"); 
        require(lastSoldTicketId < currentMintedTicketId, "No tickets for sale");
        lastSoldTicketId += 1;
        eventOrganiser.transfer(totalTicketPrice);

        // Return the excess Ether if too much was provided
        payable(given_address).transfer(msg.value - totalTicketPrice); 

        // Transfer ticket ownership to purchasing party 
        _safeTransfer(eventOrganiser, given_address, lastSoldTicketId);

        // Update previous owner
        tickets[lastSoldTicketId].prevOwner = eventOrganiser;
    }
    
}
