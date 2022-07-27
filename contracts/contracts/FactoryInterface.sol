// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

interface FactoryInterface {
    function addAssetPrice(
        uint128 asset,
        uint64 timestamp,
        uint256 priceValue,
        int32 priceExp
    ) external;

    function factoryOwner() external view returns (address);

    function transferFactoryOwnership(address newOwner) external;

    function getPriceStore(uint128 asset) external view returns (address);
}
