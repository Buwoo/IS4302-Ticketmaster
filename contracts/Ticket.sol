// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.20;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";

contract Ticket is ERC721 {
    address payable eventOrganiser; 
    string eventName; 
    string eventSymbol; 
    uint256 currentTicketId; 
    uint256 lastSoldTicketId; 
    uint256 numberOfTicketsForSale; 
    uint256 totalTicketSupply; 
    uint256 ticketPrice; 
    uint256 commissionFee; 

    struct TicketInfo {
        uint256 currTicketPrice; 
        bool canBeResold; 
    }

    mapping (uint256 => TicketInfo) tickets; 

    constructor(
        string memory _eventName, 
        string memory _eventSymbol, 
        uint256 _totalTicketSupply, 
        uint256 _ticketPrice, 
        uint256 _commissionFee) 
        ERC721(_eventName, _eventSymbol) {

        eventOrganiser = payable(msg.sender); 
        eventName = _eventName; 
        eventSymbol = _eventSymbol; 
        currentTicketId = 0; 
        lastSoldTicketId = 0; 
        numberOfTicketsForSale = 0;
        totalTicketSupply = _totalTicketSupply; 
        ticketPrice = _ticketPrice * 1 ether; 
        commissionFee = _commissionFee; 
    }

    modifier onlyEventOrganiser() {
        require(msg.sender == eventOrganiser, "Only the Event Organiser can perform this action");
        _; 
    }

    //Getter Functions

    function getTicketPrice() public view returns (uint256) {
        return ticketPrice; 
    }

    //Tickets start from ID = 1 
    function mintTicket(bool _canBeResold) onlyEventOrganiser public payable {
        currentTicketId+=1;
        _mint(msg.sender, currentTicketId);
        tickets[currentTicketId] = TicketInfo({
            currTicketPrice: ticketPrice, 
            canBeResold: _canBeResold
        }); 
        numberOfTicketsForSale+=1;
    }   

    function bulkMintTickets(uint256 nrOfTickets) onlyEventOrganiser public {
    }

    //Purchase tix from the event organiser (official purchasing means)
    function buyTicket() public payable {
        uint256 totalTicketPrice = ticketPrice + commissionFee; 
        require(msg.value >= totalTicketPrice, "Insufficient ETH to purchase ticket"); 
        require(numberOfTicketsForSale > 0, "No tickets are for sale");
        lastSoldTicketId+=1;
        eventOrganiser.transfer(totalTicketPrice);
        payable(msg.sender).transfer(msg.value - totalTicketPrice); //Return the excess Ether if too much was provided 
        _safeTransfer(eventOrganiser, msg.sender, lastSoldTicketId); //transfer ticket ownership to purchasing party 
        numberOfTicketsForSale-=1;
    }
    
}