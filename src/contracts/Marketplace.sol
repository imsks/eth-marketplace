pragma solidity >=0.4.22 <0.9.0;

contract Marketplace {
    string public name;
    uint256 public productCount;

    constructor() public {
        name = "Eth Marketplace";
    }

    mapping(uint256 => Product) public products;

    event ProductCreated(
        uint256 id,
        string name,
        uint256 price,
        address payable owner,
        bool purchased
    );

    event ProductPurchased(
        uint256 id,
        string name,
        uint256 price,
        address payable owner,
        bool purchased
    );

    struct Product {
        uint256 id;
        string name;
        uint256 price;
        address payable owner;
        bool purchased;
    }

    function createProduct(string memory _name, uint256 _price) public {
        // Require a valid name
        require(bytes(_name).length > 0);
        // Require a valid price
        require(_price > 0);
        // Increment product count
        productCount++;
        products[productCount] = Product(
            productCount,
            _name,
            _price,
            msg.sender,
            false
        );
        // Trigger an event
        emit ProductCreated(productCount, _name, _price, msg.sender, false);
    }

    function purchaseProduct(uint256 _productId) public payable {
        // Get product details
        Product memory _product = products[_productId];

        address payable _seller = _product.owner;

        // Conditions to sell a product
        // 1. Require a valid product id
        // 2.  Check if buyer is valid ie. Owner can't buy their own product
        // 3. Check if product is already purchased
        require(
            _product.id == _productId &&
                msg.sender != _seller &&
                !_product.purchased &&
                _product.price == msg.value
        );

        // Update product
        _product.purchased = true;
        _product.owner = msg.sender;
        products[_productId] = _product;

        // Pay seller in ethers
        address(_seller).transfer(msg.value);

        // Trigger an event
        emit ProductPurchased(
            productCount,
            _product.name,
            _product.price,
            msg.sender,
            true
        );
    }
}
