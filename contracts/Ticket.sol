// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.20;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";

contract Ticket is ERC721 {
    address payable eventOrganiser; 
    string eventName; 
    string eventSymbol; 
    uint256 currentMintedTicketId; 
    uint256 lastSoldTicketId; // This Id <= currentMintedTicketId
    uint256 totalTicketSupply; 
    uint256 category; 
    uint256 ticketPrice; // in wei 
    uint256 commissionFee; // in wei

    struct TicketInfo {
        uint256 category; // Seat section/category: To decide if we want to include it in the smart contract
        uint256 currTicketPrice; 
        bool canBeResold; 
    }

    mapping (uint256 => TicketInfo) tickets; 

    constructor(
        string memory _eventName, 
        string memory _eventSymbol, 
        uint256 _totalTicketSupply, 
        uint256 _category, 
        uint256 _ticketPrice, 
        uint256 _commissionFee) 
        ERC721(_eventName, _eventSymbol) {

        eventOrganiser = payable(msg.sender); 
        eventName = _eventName; 
        eventSymbol = _eventSymbol; 
        currentMintedTicketId = 0; 
        lastSoldTicketId = 0; 
        totalTicketSupply = _totalTicketSupply; 
        category = _category; 
        ticketPrice = _ticketPrice;
        commissionFee = _commissionFee; 
    }

    modifier onlyEventOrganiser() {
        require(msg.sender == eventOrganiser, "Only the Event Organiser can perform this action");
        _; 
    }

    // Getter Functions
    function getTicketPrice() public view returns (uint256) {
        return ticketPrice; 
    }

    // Tickets start from ID = 1 
    // Main function to mint tickets 
    function mintTicket(bool _canBeResold) onlyEventOrganiser public {
        require(currentMintedTicketId <= totalTicketSupply, "Cannot mint more tickets, total supply reached"); 
        currentMintedTicketId+=1;
        _mint(msg.sender, currentMintedTicketId);
        tickets[currentMintedTicketId] = TicketInfo({
            category: category,
            currTicketPrice: ticketPrice, 
            canBeResold: _canBeResold
        }); 
    }   

    // Allow for the bulk minting of tickets 
    function bulkMintTickets(uint256 _nrOfTickets, bool _canBeResold) onlyEventOrganiser public {
        require(currentMintedTicketId + _nrOfTickets <= totalTicketSupply, "Cannot mint more tickets, total supply reached"); 
        for (uint i = 0; i < _nrOfTickets; i++) {
            mintTicket(_canBeResold); 
        }
    }

    // Purchase tix from the event organiser (official purchasing means)
    function buyTicket() public payable {
        uint256 totalTicketPrice = ticketPrice + commissionFee; 
        require(msg.value >= totalTicketPrice, "Insufficient ETH to purchase ticket"); 
        require(lastSoldTicketId < currentMintedTicketId, "No tickets for sale");
        lastSoldTicketId+=1;
        eventOrganiser.transfer(totalTicketPrice);
        payable(msg.sender).transfer(msg.value - totalTicketPrice); //Return the excess Ether if too much was provided 
        _safeTransfer(eventOrganiser, msg.sender, lastSoldTicketId); //transfer ticket ownership to purchasing party 
    }
    
}