// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

import "./Ticket.sol";

contract TicketMarketplace {
    Ticket public TicketContract; 
    mapping (uint256 => uint256) Buyabletickets; //ticketID -> ticketPrice
    uint256 upperBoundRatio; //TOCHECK changed to ratio to allow this value to be used for all ticket prices of multiple categories
    uint256[] allTickets; //to keep track of all tickets available

    constructor(address _TicketContract, uint256 maxPrice) {
        TicketContract = Ticket(_TicketContract);    
        upperBoundRatio = maxPrice;
    }

    //check for FAIR ticket pricing
    modifier priceSufficient(uint256 askingPrice, uint256 maxPriceRatio, uint256 ticketUUID) {
        require(askingPrice >= ticketUUID * maxPriceRatio, "nice try bloke go take your scams somewhere else!"); //TODO get the OG price of ticketID instead of [ticketUUID]
        _;
    }

    //check for ownership of a ticket
    modifier ownerOnly(address senderAddress, uint256 ticketUUID) {
        require(ticketUUID > 0, "try owning a ticket bloke!"); //TODO get the owner of the ticket instead of the placeholder!
        _;
    }
    
    modifier ticketExists(uint256 ticketUUID) {
        require(Buyabletickets[ticketUUID] != 0, "who's ticket are you trying to buy you FOOL?");//TODO - ensure that 0 is not a valid ticket price
        _;
    }

    //ensure that enough money is spent on buying the ticket
    modifier sufficientValue(uint256 ticketUUID, uint256 value) {
        require(Buyabletickets[ticketUUID] > value, "get your broke ass outta here");
        _;
    }

    function listTicket(uint256 askingPrice, uint256 ticketUUID) public priceSufficient(askingPrice, upperBoundRatio, ticketUUID) ownerOnly(msg.sender, ticketUUID) {
        Buyabletickets[ticketUUID] = askingPrice;
        allTickets.push(ticketUUID);
    }

    //function buyTicket(string memory eventName, uint categoryNo) public { //do we not want them to specify a precise ticket? - if not how does cost resolve?
    function buyTicket(uint256 ticketUUID) public payable ticketExists(ticketUUID) sufficientValue(ticketUUID, msg.value) { 
        uint256 price = Buyabletickets[ticketUUID];
        address payable recepient = payable(msg.sender); //TODO - how do i get the ticket owner - replace placeholder msg.sender?
        //make payment
        recepient.transfer(price);
        //TODO - make ticket transfer
        Buyabletickets[ticketUUID] = 0; //set the ticket status to invalid
        removeElement(ticketUUID);
    }

    //remove ticketUUID from the public list
    function removeElement(uint256 ticketUUID) public {
        for (uint256 i = 0; i < allTickets.length; i++) {
            if (allTickets[i] == ticketUUID) {
                allTickets[i] = allTickets[allTickets.length - 1];
                allTickets.pop();
                break;
            }
        }
    }

    function getTicketsForSale(string memory eventName, uint categoryNo) public view returns(uint256[] memory) {
        //iterate through ticket to find tickets that 
        //TODO - how to search category number and eventName?
        return allTickets;
    }

    //function viewPriceOfTicketOnSale(string memory eventName, uint categoryNo) public {
    function getPriceOfTicketOnSale(uint256 ticketUUID) public view ticketExists(ticketUUID) returns(uint256) {
        return Buyabletickets[ticketUUID];
    }

    function getMarketplaceCommission() public view returns (uint256) {
        return upperBoundRatio;
    }
}

