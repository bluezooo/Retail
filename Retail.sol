// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Import OpenZeppelin's ERC20 implementation
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * ERC20 Token-based retail marketplace with buyer/seller registration, transactions, returns, and automatic penalties.
 */
contract Retail is ERC20 {
    struct Buyer {
        string name;
        string email;
        string shippingAddr;
        bool isRegistered;
    }

    struct Seller {
        bool isRegistered;
        uint256 deposit;
    }

    struct Product {
        string name;
        uint256 price; // Price in ERC20 tokens
        string url;
        uint256 stock;
        bool exists;
    }

    enum TransactionStatus { Initiated, ReturnRequested, ReturnApproved, Completed }

    struct Transaction {
        address buyer;
        uint256 productId;
        uint256 quantity;
        uint256 totalCost;
        TransactionStatus status;
        bool exists;
    }

    // -----------------------------
    // State Variables
    // -----------------------------

    // Buyer registry
    mapping(address => Buyer) public buyers;

    // Seller registry
    Seller public seller;
    address public sellerAddress;

    // Products mapping
    mapping(uint256 => Product) public products;
    uint256 public nextProductId;

    // Wish lists
    mapping(address => uint256[]) public wishLists;

    // Transactions mapping
    mapping(uint256 => Transaction) public transactions;
    uint256 public nextTransactionId;

    // Exchange rate: 1 ETH = 1000 RTL
    uint256 public tokensPerEther = 1000;

    // Penalty Tracking
    uint256 public returnRequestCount;
    uint256 public returnApproveCount;
    uint256 public penaltyThreshold = 0; // 0.5 of total transactions
    uint256 public penaltyAmount = 100; // Tokens to deduct as penalty

    // -----------------------------
    // Events
    // -----------------------------

    event BuyerRegistered(address indexed buyer);
    event BuyerProfileUpdated(address indexed buyer);
    event SellerRegistered(address indexed seller, uint256 deposit);
    event ProductAdded(uint256 indexed productId, string name, uint256 price);
    event ProductUpdated(uint256 indexed productId, string name, uint256 price);
    event TransactionInitiated(uint256 indexed transactionId, address indexed buyer, uint256 productId, uint256 quantity);
    event ReturnRequested(uint256 indexed transactionId);
    event ReturnApproved(uint256 indexed transactionId);
    event TransactionCompleted(uint256 indexed transactionId);
    event PenaltyImposed(uint256 amount);
    event DebugBalance(uint256 contractBalance);

    // -----------------------------
    // Constructor
    // -----------------------------

    constructor(uint256 initialSupply) ERC20("RetailToken", "RTL") {
        // Override decimals to 0
        // Since OpenZeppelin's ERC20 has decimals as 18 by default, we need to override it
        // Solidity doesn't allow overriding return values in derived contracts directly
        // Thus, we need to create a new ERC20 with decimals overridden.

        // Mint initial supply to contract's address
        _mint(address(this), initialSupply);
    }

    function decimals() public view virtual override returns (uint8) {
        return 0;
    }

    /**
     * Buy ERC20 tokens by sending Ether. 1 ETH = 1000 ERC20 tokens.
     */
    function buyTokens() external payable {
        require(msg.value > 0, "Send ETH to buy tokens");
        uint256 contractBalance = balanceOf(address(this));
        emit DebugBalance(contractBalance); // To log the balance for debugging

        uint256 tokensToBuy = msg.value * tokensPerEther / 10**18;
        require(balanceOf(address(this)) >= tokensToBuy,"Not enough tokens in contract. ");


        // Transfer tokens to buyer
        _transfer(address(this), msg.sender, tokensToBuy);
    }

    /**
     * Sell RTL tokens to receive Ether. 1000 RTL = 1 ETH.
     * @param tokenAmount Number of tokens to sell.
     */
    function sellTokens(uint256 tokenAmount) external {
        require(tokenAmount > 0, "Specify token amount to sell");
        require(balanceOf(msg.sender) >= tokenAmount, "Insufficient token balance");

        uint256 etherAmount = tokenAmount *10**18 / tokensPerEther ;
        require(address(this).balance >= etherAmount, "Not enough ETH in contract");

        // Transfer tokens from seller to contract
        _transfer(msg.sender, address(this), tokenAmount);

        // Transfer Ether to seller
        payable(msg.sender).transfer(etherAmount);
    }

    // -----------------------------
    // Buyer Functions
    // -----------------------------

    /**
     * Register as a buyer. Only one profile per address.
     * @param _name Buyer's name.
     * @param _email Buyer's email.
     * @param _shippingAddress Buyer's shipping address.
     */
    function registerBuyer(string memory _name, string memory _email, string memory _shippingAddress) external {
        require(!buyers[msg.sender].isRegistered, "Already registered as buyer");
        require(msg.sender != sellerAddress, "Seller cannot be a buyer");

        buyers[msg.sender] = Buyer({
            name: _name,
            email: _email,
            shippingAddr: _shippingAddress,
            isRegistered: true
        });

        emit BuyerRegistered(msg.sender);
    }

    /**
     * Update buyer's profile information.
     * @param _name New name.
     * @param _email New email.
     * @param _shippingAddress New shipping address.
     */
    function updateBuyer(string memory _name, string memory _email, string memory _shippingAddress) external {
        require(buyers[msg.sender].isRegistered, "Not a registered buyer");

        buyers[msg.sender].name = _name;
        buyers[msg.sender].email = _email;
        buyers[msg.sender].shippingAddr = _shippingAddress;

        emit BuyerProfileUpdated(msg.sender);
    }

    /**
     * Get buyer's profile information.
     * @return name Buyer's name.
     * @return email Buyer's email.
     * @return shippingAddr Buyer's shipping address.
     */
    function getBuyerProfile() external view returns (string memory name, string memory email, string memory shippingAddr) {
        require(buyers[msg.sender].isRegistered, "Not a registered buyer");

        Buyer memory buyer = buyers[msg.sender];
        return (buyer.name, buyer.email, buyer.shippingAddr);
    }

    /**
     * Get user's token balance in RTL.
     * @return balance Token balance of the user.
     */
    function getBalance() external view returns (uint256 balance) {
        return balanceOf(msg.sender);
    }


    // -----------------------------
    // Seller Functions
    // -----------------------------

    /**
     * Register as the seller. Only one seller allowed. Seller cannot be a buyer.
     * @param _deposit Number of tokens to deposit as security.
     */
    function registerSeller(uint256 _deposit) external {
        require(!seller.isRegistered, "Seller already registered");
        require(!buyers[msg.sender].isRegistered, "Buyer cannot be seller");
        require(balanceOf(msg.sender) >= _deposit, "Insufficient tokens for deposit");

        sellerAddress = msg.sender;
        seller = Seller({
            isRegistered: true,
            deposit: _deposit
        });

        // Transfer deposit tokens from seller to contract
        _transfer(msg.sender, address(this), _deposit);

        emit SellerRegistered(msg.sender, _deposit);
    }



    // -----------------------------
    // Product Functions
    // -----------------------------

    /**
     * Add a new product to the marketplace.
     * @param _name Product name.
     * @param _price Product price in RTL tokens.
     * @param _url Product URL.
     * @param _stock Initial inventory.
     */
    function addProduct(string memory _name, uint256 _price, string memory _url, uint256 _stock) external {
        require(msg.sender == sellerAddress, "Only seller can add products");

        products[nextProductId] = Product({
            name: _name,
            price: _price,
            url: _url,
            stock: _stock,
            exists: true
        });

        emit ProductAdded(nextProductId, _name, _price);
        nextProductId++;
    }

    /**
     * Update an existing product's information.
     * @param _productId ID of the product to update.
     * @param _name New name.
     * @param _price New price in RTL tokens.
     * @param _url New URL.
     * @param _stock New stock quantity.
     */
    function updateProduct(uint256 _productId, string memory _name, uint256 _price, string memory _url, uint256 _stock) external {
        require(msg.sender == sellerAddress, "Only seller can update products");
        require(products[_productId].exists, "Product does not exist");

        products[_productId].name = _name;
        products[_productId].price = _price;
        products[_productId].url = _url;
        products[_productId].stock = _stock;

        emit ProductUpdated(_productId, _name, _price);
    }

    /**
     * List all products in the marketplace.
     * @return productIds Array of product IDs.
     * @return names Array of product names.
     * @return prices Array of product prices.
     * @return urls Array of product URLs.
     * @return stocks Array of product stocks.
     */
    function listProducts() external view returns (
        uint256[] memory productIds,
        string[] memory names,
        uint256[] memory prices,
        string[] memory urls,
        uint256[] memory stocks
    ) {
        productIds = new uint256[](nextProductId);
        names = new string[](nextProductId);
        prices = new uint256[](nextProductId);
        urls = new string[](nextProductId);
        stocks = new uint256[](nextProductId);

        for(uint256 i = 0; i < nextProductId; i++) {
            if(products[i].exists){
                productIds[i] = i;
                names[i] = products[i].name;
                prices[i] = products[i].price;
                urls[i] = products[i].url;
                stocks[i] = products[i].stock;
            }
        }

        return (productIds, names, prices, urls, stocks);
    }



    // -----------------------------
    // Wish List Functions
    // -----------------------------

    /**
     * Add a product to the user's wish list.
     * @param _productId ID of the product to add.
     */
    function addToWishList(uint256 _productId) external {
        require(products[_productId].exists, "Invalid product ID");

        wishLists[msg.sender].push(_productId);
    }

    /**
     * Get the user's wish list.
     * @return productIds Array of product IDs in the wish list.
     */
    function getWishList() external view returns (uint256[] memory productIds) {
        return wishLists[msg.sender];
    }

    // -----------------------------
    // Transaction Functions
    // -----------------------------

    /**
     * Initiate a new transaction to purchase a product.
     * @param _productId ID of the product to purchase.
     * @param _quantity Quantity to purchase.
     */
    function initiateTX(uint256 _productId, uint256 _quantity) external {
        require(buyers[msg.sender].isRegistered, "Must be a registered buyer");
        require(products[_productId].exists, "Invalid product");
        require(products[_productId].stock >= _quantity, "Insufficient stock");

        uint256 totalCost = products[_productId].price * _quantity;
        require(balanceOf(msg.sender) >= totalCost, "Insufficient RTL tokens");

        // Transfer tokens from buyer to contract (escrow)
        _transfer(msg.sender, address(this), totalCost);

        // Create transaction record
        transactions[nextTransactionId] = Transaction({
            buyer: msg.sender,
            productId: _productId,
            quantity: _quantity,
            totalCost: totalCost,
            status: TransactionStatus.Initiated,
            exists: true
        });

        // Update product stock
        products[_productId].stock -= _quantity;

        emit TransactionInitiated(nextTransactionId, msg.sender, _productId, _quantity);
        nextTransactionId++;
    }

    /**
     * Get transactions for the caller. Buyers see their own, seller sees all.
     * @return ids Array of transaction IDs.
     * @return buyersList Array of buyer addresses.
     * @return productIds Array of product IDs.
     * @return quantities Array of quantities.
     * @return totalCosts Array of total costs.
     * @return statuses Array of transaction statuses as strings.
     */
    function getTX() external view returns (
        uint256[] memory ids,
        address[] memory buyersList,
        uint256[] memory productIds,
        uint256[] memory quantities,
        uint256[] memory totalCosts,
        string[] memory statuses
    ) {
        uint256 count = 0;
        if(msg.sender == sellerAddress){
            count = nextTransactionId;
        }
        else{
            // Count number of transactions for this buyer
            for(uint256 i = 0; i < nextTransactionId; i++){
                if(transactions[i].buyer == msg.sender){
                    count++;
                }
            }
        }

        ids = new uint256[](count);
        buyersList = new address[](count);
        productIds = new uint256[](count);
        quantities = new uint256[](count);
        totalCosts = new uint256[](count);
        statuses = new string[](count);

        uint256 index = 0;
        for(uint256 i = 0; i < nextTransactionId; i++){
            if(msg.sender == sellerAddress || transactions[i].buyer == msg.sender){
                ids[index] = i;
                buyersList[index] = transactions[i].buyer;
                productIds[index] = transactions[i].productId;
                quantities[index] = transactions[i].quantity;
                totalCosts[index] = transactions[i].totalCost;
                statuses[index] = transactionStatusToString(transactions[i].status);
                index++;
            }
        }

        return (ids, buyersList, productIds, quantities, totalCosts, statuses);
    }

    /**
     * Convert TransactionStatus enum to string.
     * @param status TransactionStatus enum value.
     * @return statusStr Transaction status as string.
     */
    function transactionStatusToString(TransactionStatus status) internal pure returns (string memory statusStr) {
        if(status == TransactionStatus.Initiated){
            return "Initiated";
        }
        else if(status == TransactionStatus.ReturnRequested){
            return "Return Requested";
        }
        else if(status == TransactionStatus.ReturnApproved){
            return "Return Approved";
        }
        else{
            return "Completed";
        }
    }

    /**
     * Request a return for a transaction before completion.
     * @param _transactionId ID of the transaction to return.
     */
    function requestReturn(uint256 _transactionId) external {
        Transaction storage txData = transactions[_transactionId];
        require(txData.exists, "Transaction does not exist");
        require(txData.buyer == msg.sender, "Not your transaction");
        require(txData.status == TransactionStatus.Initiated, "Cannot request return in current state");

        txData.status = TransactionStatus.ReturnRequested;
        returnRequestCount++;

        emit ReturnRequested(_transactionId);

        // Check if penalty conditions are met
        checkPenalty();
    }

    /**
     * Approve a return request. Only seller can approve.
     * @param _transactionId ID of the transaction to approve return.
     */
    function approveReturn(uint256 _transactionId) external {
        require(msg.sender == sellerAddress, "Only seller can approve returns");

        Transaction storage txData = transactions[_transactionId];
        require(txData.exists, "Transaction does not exist");
        require(txData.status == TransactionStatus.ReturnRequested, "No return requested");

        txData.status = TransactionStatus.ReturnApproved;
        returnApproveCount++;

        // Refund tokens to buyer
        _transfer(address(this), txData.buyer, txData.totalCost);

        emit ReturnApproved(_transactionId);

        // Check if penalty conditions are met
        checkPenalty();
    }

    /**
     * Complete a transaction. Only buyer can mark as completed.
     * @param _transactionId ID of the transaction to complete.
     */
    function completeTX(uint256 _transactionId) external {
        Transaction storage txData = transactions[_transactionId];
        require(txData.exists, "Transaction does not exist");
        require(txData.buyer == msg.sender, "Not your transaction");
        require(txData.status == TransactionStatus.Initiated, "Cannot complete in current state");

        txData.status = TransactionStatus.Completed;

        // Transfer tokens to seller
        _transfer(address(this), sellerAddress, txData.totalCost);
        seller.deposit += txData.totalCost;

        emit TransactionCompleted(_transactionId);
    }




    // -----------------------------
    // Penalty Functions
    // -----------------------------

    /**
     * Check if penalty conditions are met and impose penalty if necessary.
     * Conditions:
     * - Return requests count >= 50% of total transactions.
     * - Return approval rate < 1/3 of return requests.
     */
    function checkPenalty() internal {
        uint256 totalTransactions = nextTransactionId;
        if(totalTransactions == 0){
            return;
        }

        uint256 halfTransactions = totalTransactions / 2;
        uint256 oneThirdsReturnApprovals = (returnRequestCount) / 3;

        if(returnRequestCount >= halfTransactions || returnApproveCount < oneThirdsReturnApprovals){
            imposePenalty();
        }
    }

    /**
     * Impose a penalty on the seller by deducting tokens from their tokens.
     */
    function imposePenalty() internal {
        require(seller.isRegistered, "No seller registered");
        require(balanceOf(sellerAddress) >= penaltyAmount, "Insufficient tokens for penalty");

        // Burn the penalty tokens by transferring to zero address

        _transfer(sellerAddress, address(this), penaltyAmount);

        // Reset penalty tracking counts
        returnRequestCount = 0;
        returnApproveCount = 0;

        emit PenaltyImposed(penaltyAmount);
    }



    // -----------------------------
    // Fallback Functions
    // -----------------------------

    // Allow contract to receive Ether
    receive() external payable {}
}
