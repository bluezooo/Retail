# IEMS5725 Project Report

##### WANG YUHANG 1155225714

## Introduction

Blockchain is shaking up the retail world by making transactions more transparent, secure, and efficient. This project builds a smart contract about retail system using Solidity.

## Advantages of Using Blockchain in Retail Transactions

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

## Problems of the Current Project and Potential Solutions

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

## Conclusion

Blockchain offers great benefits for retail, such as increased transparency, security, and efficiency. However, the current `Retail` smart contract has some challenges like scalability, access control, penalty robustness, token economics, and privacy. By addressing these issues with the suggested solutions, the project can become a stronger, more secure, and user-friendly decentralized retail marketplace.