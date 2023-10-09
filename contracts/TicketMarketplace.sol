// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

import "./Ticket.sol";

contract TicketMarketplace {
    Ticket public TicketContract; 

    constructor(address _TicketContract) {
        TicketContract = Ticket(_TicketContract);
    }


}

