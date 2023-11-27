[![Solidity Version](https://img.shields.io/badge/Solidity-0.8.20-blue.svg)](https://solidity.readthedocs.io/)

# IS4302-Ticketmaster

## Problem Statement

In the realm of ticketing sale and resale, customers encounter two primary challenges.

- Firstly, this revolves around the issue of transaction fees, which can manifest as undisclosed commissions and concealed costs integrated into the total ticket price as it moves from the initial creators, through intermediaries, and ultimately to the end consumers.

- Secondly, it pertains to the infiltration of malicious bots in the ticket purchasing process. These bots are used for scalping, to acquire tickets in large quantities, preventing concert fans who actually want to go for these concerts from getting the tickets. Scalper would subsequently resell them on a secondary market at substantially inflated prices.

Henceforth, this project seeks to introduce the application of blockchain technology as the panacea that addresses the pain points that customers face in the ticketing journey. Please refer the steps and instructions below for more clarity on the usage.

## Contracts

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

```bash
cd IS4302-Ticketmaster
npm install
```

#### Running the application

```bash
FILL THIS UP
```

#### Unit testing using Hardhat

Use the package manager [npm](https://docs.npmjs.com/downloading-and-installing-node-js-and-npm) to install npm and Node.js. Once npm and Node.js is installed, run the following code to install hardhat

```bash
npm init
npm install --save-dev hardhat
npx hardhat init
```

## License

This project is licensed under the [MIT](https://spdx.org/licenses/GPL-3.0.html) License
