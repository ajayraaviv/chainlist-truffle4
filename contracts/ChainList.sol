pragma solidity ^0.4.18;

import "./Ownable.sol";

contract ChainList is Ownable {
  //custom types
  struct Article {
    uint id;
    address seller;
    address buyer;
    string name;
    string description;
    uint256 price;
  }

  //state variables
  mapping (uint => Article) public articles;
  uint articleCounter;

  //events
  event LogSellArticle(
    uint indexed _id,
    address indexed _seller,
    string _name,
    uint256 _price
    );
  event LogBuyArticle(
    uint indexed _id,
    address indexed _seller,
    address indexed _buyer,
    string _name,
    uint256 _price
    );

  // deactivate the contract
  function kill() public onlyOwner {
    selfdestruct(owner);
  }

  // sell an article
  function sellArticle(string _name, string _description, uint256 _price) public {
    // increment the article counter
    articleCounter++;
    articles[articleCounter] = Article(
            articleCounter,
            msg.sender,
            0x0,
            _name,
            _description,
            _price);
    LogSellArticle(articleCounter, msg.sender, _name, _price);
  }

  //get the number of articles
  function getNumberOfArticles() public view returns (uint) {
    return articleCounter;
  }

  // fetch and return all article IDs for articles still for sale
  function getArticlesForSale() public view returns (uint[]) {
    // prepare output array
    uint[] memory articleIds = new uint[](articleCounter);

    uint numberOfArticlesForSale = 0;
    // iterate over articles
    for(uint i = 1; i <= articleCounter; i++) {
      //keep the ID if the article is still for sale
      if(articles[i].buyer == 0) {
        articleIds[numberOfArticlesForSale] = articles[i].id;
        numberOfArticlesForSale++;
      }
    }

    // copy the articleIds array into a smaller forSale array
    uint[] memory forSale = new uint[](numberOfArticlesForSale);
    for(uint j = 0; j < numberOfArticlesForSale; j++) {
      forSale[j] = articleIds[j];
    }
    return forSale;
  }

  function buyArticle(uint _id) payable public {
    //throw - legacy, assert - internal errors, require - preconditions, revert - imerative exceptions
    //1 - value gets refunded
    //2 - state changes reverted
    //3 - function interrupted
    //4 - gas spend until that point is not returned
    //5 - REVERT opcode is returned
    //we check whether there is an article for sale

    require(articleCounter > 0);

    require(_id > 0 && articleCounter >= _id);

    //we retrieve the article form the mapping
    Article storage article = articles[_id];

    // we check that the article has not been not sold
    require(article.buyer == 0x0);

    //we don't allow the seller to buy his own article
    require(msg.sender != article.seller);

    //we check value sent corresponds to the price of the article
    require(msg.value == article.price);

    // keep track of the buyer's information
    article.buyer = msg.sender;

    // the buyer can pay the seller
    article.seller.transfer(msg.value);

    //trigger the event
    LogBuyArticle(_id, article.seller, article.buyer, article.name, article.price);
  }




}
