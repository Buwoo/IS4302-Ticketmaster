[![Solidity Version](https://img.shields.io/badge/Solidity-0.8.20-blue.svg)](https://solidity.readthedocs.io/)

# IS4302-Ticketmaster

## Problem Statement

In the realm of ticketing sale and resale, customers encounter two primary challenges.

- Firstly, it revolves around the issue of transaction fees, which manifests as undisclosed commissions and concealed costs integrated into the overall ticket price as we traverse down the ticket lifecycle.

- Secondly, it pertains to the infiltration of malicious bots in the ticketing process. These bots are used for scalping, where tickets are acquired in large quantities. This prevents concert fans who actually want to go for these concerts from getting them. Scalpers could subsequently resell them on a secondary market at substantially inflated prices in order to reap a quick profit.

Henceforth, this project seeks to introduce the application of blockchain technology as the panacea that addresses the pain points that customers face in the ticketing journey. Please refer the steps and instructions below for more clarity on the usage.

## Contracts

Our blockchain application operates on the premise of 3 smart contracts that are detailed further below:

1. **Ticket.sol:**
   Builds upon the existing ERC-721 (NFT) framework provided by the OpenZeppelin library. This contract contains functions that allow the transfer and ownership of these ERC tokens as Tickets. The ERC-721 framework was used such that each created NFT ticket will be unique and remain as collectibles at the end of the event. All tickets minted within this smart contract are for the same event and seat categories. The ticket contains multiple shared attributes which are uniform across all tickets created from this smart contract, including the event name, event symbol, category number, event organizer address, original ticket price, total ticket supply etc. Besides getter functions, there are also key functions like mintTicket and bulkMintTickets that create new ticket(s), and buyTicket that allow the sale of tickets from the main ticketing organizer to event patrons.

2. **TicketMarketplace.sol:**
   Acts as a marketplace where users can buy and list tickets on the resale market. The ticket marketplace will include an array of Ticket contracts. This data structure allows us to keep track of the tickets available for resale, removing them from the marketplace array when these tickets are successfully bought over. We extract the ceiling value for the resale price of a ticket from the Ticketmaster, where we can then control the resale prices from reaching exorbitant amounts.

3. **TicketMaster.sol:**
   Acts as a “Ticket” management system. that stores the various category Ticket smart contracts. For instance, if there are 3 categories of tickets for a certain event, there will be 3 separate smart contracts for the 3 categories of Tickets stored within an array called allTicketAddresses. This smart contract acts as a wrapper, allowing event patrons to purchase tickets (from the correct Ticket smart contract) depending on what category ticket they intend to buy.

## Installation

#### Cloning the repository

```bash
git clone https://github.com/Buwoo/IS4302-Ticketmaster.git
```

#### Installing dependencies

Use the package manager [npm](https://docs.npmjs.com/downloading-and-installing-node-js-and-npm) to install npm and Node.js. Once npm and Node.js is installed, run the following code.

```bash
cd IS4302-Ticketmaster
npm install
```

## Testing on Remix IDE

3 addresses: 
- event organiser 1/admin, initialising Tickets, TicketMaster, and TicketMarketplace
- customer A
- customer B 

note: the way we designed it, each Ticket, TicketMaster, and TicketMasterplace is for 1 event

**1. Create 2 Ticket contracts of different categories**

using event organiser 1, initialise:
Ticket 1: (Taylor Swift 5 Dec, TS0512, 1, 1, 80, 10)
for one of the categories, set totalSupply to 1 for demonstration of what happens if there are no more tickets for sale 
- getEventName() should return Taylor Swift 5 Dec
- getEventSymbol() should return TS0512
- getCategory() should return 1
- getOriginalTicketPrice() should return 80
- getCommissionFee() should return 10

Ticket 2: (Taylor Swift 5 Dec, TS0512, 100, 2, 20, 2)
<br><br/>

**2. Minting tickets**

using event organiser 1, Ticket 1:
- mintTicket() individually
- currentMintedTicketId() should return 1
- mintTicket() again, show how theres a limit to the amount we can mint based on totalSupply
- getCurrentTicketPrice(1) should return 90, the OriginalTicketPrice, will change if resale on secondary market
- getCurrentTicketPrice(2) should give "This ticketId does not exist"
- checkOriginalMinter(1) should return authenticity of the ticket == contract owner 
- getOwnerOf(1) should return event organiser 1 address
- getPrevOwner(1) should return address(0)

Ticket 2:
- bulkMintTickets(10)

using any other address, mintTicket() will give "Only the Event Organiser can perform this action"
<br><br/>

**3. TicketMaster**
- using event organiser 1, initialise TicketMaster([Ticket 1 address, Ticket 2 address])
- getAllTicketAddresses() should return Ticket 1 address, Ticket 2 address
- getSpecificTicketAddress(1) should return Ticket 1 address
- getSpecificTicketAddress(2) should return Ticket 2 address
- getSpecificTicketAddress(3) should throw error (to add the Invalid Category Number given check?)
- findEventName() should return 'Taylor Swift 5 Dec'
- findOwner(1,1) should return event organiser 1 address
<br><br/>

**4. Primary sale (using TicketMaster)**
- using customer A, buyTicket(1) with 1000, "Insufficient ETH to purchase ticket" error, Show how need to put enough ethers to purchase
- using customer A, buyTicket(1) with 1020
- findOwner(1, uint256 ticketId) will give customer A address
- using customer A, buyTicket(1), "No tickets for sale" error, Showcase what happens if no more tickets for sale
- using customer A, buyTicket(3), "Invalid Category Number given" error
- using customer B, buyTicket(2)
<br><br/>

**5. Secondary sale (using TicketMarketplace)**
- using event organiser 1, initiate TicketMarketplace(TicketMaster address, 110, true), reselling is allowed
- customer B listTicket(1000, 1, 1), show how we cannot list tickets we dont have  TODO: ownerOnly message?
- customer A listTicket(1500, 1, 1), show how we cannot exceed the fair ticket pricing upperboundratio
- customer A listTicket(1000, 1, 1), successfully listed ticket
- customer B getTicketPrice(1, 1), Once list the ticket, check the ticket price with getTicketPrice 
- customer B delistTicket(1,1), cannot delist the ticket (since he's not the owner of the ticket) 
- customer B buyTicket(2,2), ticket not listed
- customer B buyTicket(1,1), success
- customer A listTicket(1000, 1, 1), cannot list because ticket is sold
- customer A buyTicket(1, 1), Show that the ticket is unlisted by getting user A to try buying the ticket back from user B


## License

This project is licensed under the [MIT](https://spdx.org/licenses/GPL-3.0.html) License
