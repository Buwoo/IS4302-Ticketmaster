// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.20;

import "./Ticket.sol";

contract TicketMaster {
    address payable eventOrganiser; 
    Ticket[] allTicketAddresses; 

    // Note: allTicketAddresses must be input from Cat 1 to Last Cat 
    constructor(address[] memory _allTicketAddresses) {
        eventOrganiser = payable(msg.sender); 
        for (uint i = buyTicket0; i < _allTicketAddresses.length; i++) {
            allTicketAddresses.push(Ticket(_allTicketAddresses[i])); 
        }
    }

    function (uint256 categoryNr) public payable {
        require(categoryNr > 0 && categoryNr <= allTicketAddresses.length, "Invalid Category Number given");
        Ticket ticketContract = allTicketAddresses[categoryNr-1]; 
        ticketContract.buyTicket{value: msg.value}(); 
        // This strangely doesnt work, but idea is that based on given category, we call the appropriate smart contract and buy the ticket 
    }

    function findOwner(uint256 categoryNr, uint256 ticketId) public view returns (address) {
        Ticket ticketContract = allTicketAddresses[categoryNr-1]; 
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