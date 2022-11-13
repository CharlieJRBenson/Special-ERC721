// SPDX-License-Identifier: MIT
// Creator: Charlie Benson
pragma solidity ^0.8.4;


import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";


/**
 * @dev Example for Chainlink Price Feed Getter
*/

contract ChLinkPriceFeedExample is Ownable {
    

    AggregatorV3Interface internal priceFeed;
    uint private mintPriceUSD = 1000;
    

    constructor(){
        //Set to default ETHUSD Chainlink Aggregator
        priceFeed = AggregatorV3Interface(0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e);
    }


    function getMintPriceWei() public view returns (uint){
        uint eth = uint(getLatestETHUSDPrice());
        //USD / ETHUSD = WEI
        //10^26/10^8 = 10^18
        return (mintPriceUSD * 10 ** 26)/ eth ;
    }

    function setMintPriceUSD(uint _newMintPrice) public onlyOwner{
        mintPriceUSD = _newMintPrice;
    }

    function getLatestETHUSDPrice() public view returns(int){
        //returns USD *10**8
        (
            /*uint80 roundID*/,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();
        return price;
    }

    function getPriceFeedAddr() public view returns(address){
        return address(priceFeed);
    }

    function setPriceFeedAddr(address _priceFeed) public onlyOwner {
        priceFeed = AggregatorV3Interface(_priceFeed);
    }
}
