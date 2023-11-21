// SPDX-License-Identifier: GPL-3.0

/*
Caveat - the marketplace can only work with one ticketmaster

Something srsly wrong with the ticket marketplace 
- One marketplace should not be taking on only one ticket
- One marketplace should take multiple ticketMasters, of which should have its own rules
- Can i get the ticketmaster and ticket contract through the UUID of a ticket - no you cannot! -> How to figure this out?
- I need to input the ticket marketplace and ticket master 
- Can i get the ticketmaster and ticket contract through the UUID of a ticket?
*/

pragma solidity ^0.8.20;

import "./Ticket.sol";
import "./TicketMaster.sol";

contract TicketMarketplace {
    Ticket public TicketContract; 
    TicketMaster public TicketMasterContract; 
    
    mapping (uint => mapping (uint256 => uint256)) Buyabletickets; //cat->id->price
    uint256 upperBoundRatio;
    uint256[] allTickets; //to keep track of all tickets available

    constructor(address _TicketMasterContract, uint256 maxPrice) {
        TicketContract = Ticket(_TicketMasterContract);    
        TicketMasterContract = TicketMaster(_TicketMasterContract);  
        upperBoundRatio = maxPrice;
    }

    //check for FAIR ticket pricing
    modifier priceSufficient(uint256 askingPrice, uint256 maxPriceRatio, uint256 ticketUUID, uint256 cat) {
        require(askingPrice >= TicketMasterContract.getTicket(cat).getOriginalTicketPrice(), "nice try bloke - go take your scams somewhere else!");
        _;
    }

    //check for ownership of a ticket
    modifier ownerOnly(address senderAddress, uint256 ticketUUID) {
        require(msg.sender == TicketContract.getOwnerOf(ticketUUID)); 
        _;
    }
    
    //check that the ticket exists
    modifier ticketExists(uint256 ticketUUID, uint cat) {
        require(Buyabletickets[cat][ticketUUID] != 0, "who s ticket are you trying to buy you FOOL?");
        _;
    }

    //ensure that enough money is spent on buying the ticket
    modifier sufficientValue(uint256 ticketUUID, uint256 value, uint cat) {
        require(Buyabletickets[cat][ticketUUID] > value, "get your broke ass outta here");
        _;
    }

    //list the ticket on the marketplace
    function listTicket(uint256 askingPrice, uint256 ticketUUID, uint cat) public priceSufficient(askingPrice, upperBoundRatio, ticketUUID, cat) ownerOnly(msg.sender, ticketUUID) {
        Buyabletickets[cat][ticketUUID] = askingPrice;
        allTickets.push(ticketUUID);
    }

    //function buyTicket(string memory eventName, uint categoryNo) public { //do we not want them to specify a precise ticket? - if not how does cost resolve?
    function buyTicket(uint256 ticketUUID, uint cat) public payable ticketExists(ticketUUID,cat) sufficientValue(ticketUUID, msg.value, cat) { 
        uint256 price = Buyabletickets[cat][ticketUUID];
        address payable recepient = payable(TicketContract.getOwnerOf(ticketUUID)); //get ticket owner        
        recepient.transfer(price); //make payment
        TicketContract.transferToken(recepient, msg.sender, ticketUUID); //transfer ticket
        Buyabletickets[cat][ticketUUID] = 0; //set the ticket status to invalid
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

    //TODO - return all tickets for sale, id cat and price + function overload
    function getTicketsForSale() public view returns(uint256[] memory) {
        return allTickets;
    }

    //function viewPriceOfTicketOnSale(string memory eventName, uint categoryNo) public {
    function getPriceOfTicketOnSale(uint256 ticketUUID, uint cat) public view ticketExists(ticketUUID, cat) returns(uint256) {
        return Buyabletickets[cat][ticketUUID];
    }

    function getMarketplaceCommission() public view returns (uint256) {
        return upperBoundRatio;
    }
}