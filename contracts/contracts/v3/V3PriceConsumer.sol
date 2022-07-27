// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.7;

import "./AggregatorV3Interface.sol";

contract PriceConsumerV3 {
    AggregatorV3Interface internal priceFeed;

    /**
     * Network: GAO Test
     * Aggregator: BTC/pUSD
     * Address: 0x7710C7864ac5dE4B3e56e15e0cEA0fDAc4a0403A
     */
    constructor() {
        priceFeed = AggregatorV3Interface(
            0x7710C7864ac5dE4B3e56e15e0cEA0fDAc4a0403A
        );
    }

    /**
     * Returns the latest price
     */
    function getLatestPrice() public view returns (int256) {
        (
            ,
            /*uint80 roundID*/
            int256 price, /*uint startedAt*/ /*uint timeStamp*/ /*uint80 answeredInRound*/
            ,
            ,

        ) = priceFeed.latestRoundData();
        return price;
    }
}
