# IEMS5725 Blockchain Project 

###### WANG YUHANG 1155225714




## Introduction

Blockchain is shaking up the retail world by making transactions more transparent, secure, and efficient. This project builds a smart contract about retail system using Solidity.

### Step-by-Step Guide

#### 1. Upload and Compile the Solidity code in Remix (https://remix.ethereum.org/)

#### 2. Deploy the Contract

​	Constructor Parameters: Enter `initialSupply` for total ERC20 token that be bought (e.g., `1000000`).

#### 3. Interacting with the Contract

##### a. **Token Operations**: Exchange 1 Ether for 1000 ERC 20 tokens

- **Buy Tokens**: Ensure the contract has a token balance, then enter the amount of Ether to send and click `buyTokens` function, and all purchasing will be counted in this ERC tokens.
- **Sell Tokens**: Enter the number of tokens to sell in the `sellTokens` function.

##### b. Buyer Registration, Update Profile, and View Buyer Profile

- **Register as Buyer**: Input name, email, and shipping address in string in function `registerBuyer`
  
- **Update Buyer Profile**: Use the `updateBuyer` function with new details.
  
- **View Buyer Profile**: Call the `getBuyerProfile` function and will return current `msg.sender`'s profile.

##### c. **Seller Registration and Product Management**

- **Register as Seller**:
  
  1. Ensure you're not already a buyer, and buy some tokens first before registering.
  3. Use the `registerSeller` function with the deposit amount (in ERC20 tokens).
  
- **Add or Update Product**:
  
  1. Only seller can use the `addProduct` function by providing product name, price, URL, and stock.
  2. Use the `updateProduct` function with the product ID and new details.

- **List All Products**:
  
  ​	Call the `listProducts` function to view available products. 

##### d. **Managing Wish Lists**

- **Add to Wish List**: Use the `addToWishList` function with the desired product ID.
- **View Wish List**: Call the `getWishList` function to see your saved products.

##### e. **Handling Transactions**

- **Initiate a Transaction**:
  
  1. Ensure you are a registered buyer with sufficient tokens with buying amount smaller than stock.
  2. Use the `initiateTX` function with product ID and quantity.

- **View Transactions**:
  - Buyers see their own TXs; sellers see all. Use the "getTX" function accordingly by simply clicking.

- **Request a Return (Buyer Only)**:
  
  Use the `requestReturn` function with the transaction ID.

- **Approve a Return and Refund (Seller Only)**:
  
  As the seller, use the `approveReturn` function with the transaction ID.

- **Complete a Transaction and Pay Seller**:
  
  As the buyer, use the `completeTX` function with the transaction ID, this operation is irreversible.

#### 4. Monitoring and Events

- **Event Logs**:
  - Monitor emitted events in the "Console" or "Logs" section of Remix to track actions like registrations, transactions, and penalties.

#### 5. Receiving Ether

- **Sending Ether to Contract**:
  - The contract can receive Ether via the `buyTokens` function or directly by sending Ether to the contract address.
  - Fallback function is added.

#### 6. Penalty Mechanism

- **Automatic Penalties**:
  
  - The contract automatically imposes penalties on the seller based on return conditions.
  
  - If return request is too high or the approval of return rate is too low, the seller will be punished by deducting his/her tokens.


### Advantages of Using Blockchain in Retail Transactions

1. **Transparency and Traceability**
   - Every transaction is recorded on the blockchain, making it easy to track purchases and returns.
   - Customers can verify product authenticity, reducing fraud and counterfeit items.
2. **Decentralization and Fewer Middlemen**
   - Direct transactions between buyers and sellers without needing banks or payment processors.
   - Lower fees and faster transactions since there are fewer intermediaries.
3. **Enhanced Security**
   - Blockchain’s cryptography keeps data safe from hacks and unauthorized changes.
4. **Smart Contracts Automation**
   - Automatically execute agreements, such as releasing payments when items are delivered.
   - Reduces manual work and errors, making processes smoother.
5. **Better Loyalty Programs**
   - Create secure and flexible loyalty programs using ERC20 tokens.

### Problems of the Current Project and Potential Solutions

#### 1. **Scalability Issues**

**Problem:**
- The contract uses mappings and **sequential ID**s for products and transactions. As the number grows, functions like `listProducts` and `getTX` might become slow and expensive in terms of gas fees.

**Solutions:**

- **Pagination:** Break down lists into smaller pages to handle large data sets efficiently.
- **Event-Based Tracking:** Use events to track transactions and products instead of storing everything on-chain.
- **Off-Chain Storage:** Store detailed product info off-chain (like in Inter Planetary File System (IPFS)) and reference it on-chain with hashes.

#### 2. **Limited Access Control and Role Management**

**Problem:**

- Only one seller is allowed, but the contract doesn’t fully prevent the seller from acting like a buyer or vice versa, which can cause role conflicts. If the seller generates new address and register as buyers, he/she can maliciously improve the sales amount and refund approval rate to avoid being punished.

**Solutions:**

- Add buyer activity detect module.
- Introduce trusted third-party for verification of registration.

#### 3. **Weak Penalty Mechanism**

**Problem:**

- The current penalty system is basic and may not fully capture seller misbehavior. It also lacks a way to handle disputes.

**Solutions:**

- **Advanced Metrics:** Use more detailed criteria like timely responses, and customer feedback.
- **Dispute Resolution:** Add a way for buyers and sellers to resolve disagreements, maybe with third-party arbitrators or a voting system.
- **Gradual Penalties:** Implement a tiered penalty system where repeated issues lead to bigger penalties, giving sellers a chance to improve.

#### 4. **Rigid Token Economics**

**Problem:**

- The contract has a fixed token supply and a set exchange rate with ETH, which might not adapt well to market changes, leading to liquidity problems or unstable token value.

**Solutions:**

- **Dynamic Pricing:** Adjust the token-ETH rate based on supply and demand to keep the token value stable.
- **Minting and Burning:** Allow the contract to create or destroy tokens as needed to manage supply.
- **Liquidity Pools:** Use decentralized exchanges (DEX) or liquidity pools to ensure there’s always enough token liquidity.

#### 5. **User Privacy Concerns**

**Problem:**

- Buyers’ personal info like email and shipping address are stored on-chain and are publicly accessible, raising privacy issues.

**Solutions:**
- **Data Encryption:** Encrypt personal data before storing it on the blockchain so only authorized parties can access it.
- **Off-Chain Storage with On-Chain References:** Keep sensitive info off-chain and store only references or hashes on-chain.
- **Zero-Knowledge Proofs:** Use zero-knowledge proofs to verify user information without revealing the actual data on the blockchain.



## Features：
- Buyer Registration: A user can register by generating the profile with their name, email, and shipping
address. Only one profile can be registered per address. Once registered, the buyer can view and
update/edit their own profile information.
- Seller Registration: Only one address can register as the seller by depositing a certain amount of
cryptocurrency (Ethereum coins), and the seller address is not allowed to be a buyer. Once registered,
the seller can add products for sale with a name, price, URL, and inventory (A product ID will be
generated). Only the seller address is allowed to add and update/edit product information.
- Shopping Moment: Anyone can input the product id and view the corresponding product information,
including the name, price, URL, and inventory. Everyone has a wish list and can add the product id to
his/her own list.
- Transaction Initiation: A buyer can initiate a new transaction by specifying the product ID and quantity.
The total cost of the transaction is calculated based on the selected product price. The buyer should hold enough money and transfer it to the smart contract to proceed with the transaction.
- Transaction Information: A user can only view their own transactions, while the seller can view all.
(Note that you need to consider what attributes are required in order to achieve the requirements, as
they are not explicitly specified here.)
- Return Request: A buyer can request a return before completing the transaction. The seller can get the
transaction information to see the transaction status and approve a return upon request. Once a return is approved, the money contained in the transaction should be transferred back to the buyer.
- Transaction Completion: The buyer can mark a transaction as completed. Once a transaction is completed, the total cost of the transaction should be transferred to the seller’s account. Also, no other modifications or actions can be done except viewing the transaction information.


## Conclusion

Blockchain offers great benefits for retail, such as increased transparency, security, and efficiency. However, the current `Retail` smart contract has some challenges like scalability, access control, penalty robustness, token economics, and privacy. By addressing these issues with the suggested solutions, the project can become a stronger, more secure, and user-friendly decentralized retail marketplace.
