// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.20;

import "./Ticket.sol";

contract TicketMaster {
    address payable eventOrganiser; 
    Ticket[] allTicketAddresses; 

    // Note: allTicketAddresses must be input from Cat 1 to Last Cat 
    constructor(address[] memory _allTicketAddresses) {
        eventOrganiser = payable(msg.sender); 
        for (uint i = 0; i < _allTicketAddresses.length; i++) {
            allTicketAddresses.push(Ticket(_allTicketAddresses[i])); 
        }
    }

    function buyTicket(uint256 categoryNr) public payable {
        require(categoryNr > 0 && categoryNr <= allTicketAddresses.length, "Invalid Category Number given");
        Ticket ticketContract = allTicketAddresses[categoryNr-1]; 
        ticketContract.buyTicket{value: msg.value}(); 
        // This strangely doesnt work, but idea is that based on given category, we call the appropriate smart contract and buy the ticket 
    }


}