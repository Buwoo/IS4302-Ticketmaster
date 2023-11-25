// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.20;

import "./Ticket.sol";

contract TicketMaster { //one concert
    address payable eventOrganiser; //hoster who will get the cash
    Ticket[] allTicketAddresses; //a bunch of categories

    // Note: allTicketAddresses must be input from Cat 1 to Last Cat 
    constructor(address[] memory _allTicketAddresses) {
        eventOrganiser = payable(msg.sender); 
        for (uint i = 0; i < _allTicketAddresses.length; i++) { 
            allTicketAddresses.push(Ticket(_allTicketAddresses[i])); 
        }
    }

    //get all ticket contract addresses 
    function getAllTicketAddresses() public view returns(Ticket[] memory) {
        return allTicketAddresses;
    }

    //get the ticket contract address for a specific category
    function getSpecificTicketAddress(uint256 categoryNr) public view returns(Ticket) {
        return allTicketAddresses[categoryNr-1];
    }

    function buyTicket(uint256 categoryNr) public payable {
        require(categoryNr > 0 && categoryNr <= allTicketAddresses.length, "Invalid Category Number given");
        Ticket ticketContract = getSpecificTicketAddress(categoryNr);
        ticketContract.buyTicket{value: msg.value}(payable(msg.sender)); 
        // This strangely doesnt work, but idea is that based on given category, we call the appropriate smart contract and buy the ticket 
    }

    function findOwner(uint256 categoryNr, uint256 ticketId) public view returns (address) {
        Ticket ticketContract = getSpecificTicketAddress(categoryNr);
        return ticketContract.getOwnerOf(ticketId); 
    }

    // Any getter function which doesnt require us to find the specific ticketContract, we can just use the ticketContract at id = 0 
    // E.g. to find Event Name, all ticketContracts within allTicketAddresses will have the same eventName 
    // This is unlike e.g. buy ticket, where different ticketContracts have different prices since they are referring to different tix categories
    function findEventName() public view returns (string memory) {
        Ticket ticketContract = allTicketAddresses[0]; 
        return ticketContract.getEventName();
    }
}