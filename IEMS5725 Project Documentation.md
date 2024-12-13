### IEMS5725 Project Documentation

###### WANG YUHANG 1155225714

#### Step-by-Step Guide

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
  
    

