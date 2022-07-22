// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import {PriceStoreV3 as PriceStore} from "./V3PriceStore.sol";
import "./FactoryInterface.sol";
import "./Registry.sol";
import "./Ownable.sol";

contract FactoryV3 is Ownable, FactoryInterface {
    Registry public registry;
    mapping(address => PriceStore) public stores;

    constructor(address _registry) {
        registry = Registry(_registry);
        require(
            registry.contracts(0xc6d0c7282624429b8e0dd9d19b6592fa) !=
                address(0x0), // btc not registered
            "invalid registry address"
        );
    }

    function addAssetPrice(
        uint128 asset,
        uint64 timestamp,
        uint256 priceValue,
        int32 priceExp
    ) external override onlyOwner {
        PriceStore store = getOrCreatePriceStore(asset);
        int256 answer = int256(priceValue);
        priceExp = priceExp + int8(store.decimals());
        if (priceExp > 0) {
            answer = answer * int256(10**uint32(priceExp));
        } else {
            answer = answer / int256(10**uint32(-priceExp));
        }
        store.addNewAnswer(uint256(timestamp), answer);
    }

    function transferFactoryOwnership(address newOwner)
        external
        override
        onlyOwner
    {
        transferOwnership(newOwner);
    }

    function factoryOwner() external view override returns (address) {
        return owner();
    }

    function getPriceStore(uint128 asset)
        external
        view
        override
        returns (address)
    {
        return address(stores[_getRegistryAsset(asset)]);
    }

    function getOrCreatePriceStore(uint128 _asset) public returns (PriceStore) {
        address asset = _getRegistryAsset(_asset);
        PriceStore store = stores[asset];
        if (address(store) == address(0)) {
            store = new PriceStore(asset);
            stores[asset] = store;
        }
        return store;
    }

    function setPriceStore(uint128 _asset, address _store) public onlyOwner {
        address asset = _getRegistryAsset(_asset);
        PriceStore store = PriceStore(_store);
        require(store.asset() != asset, "invalid store: asset not matched");
        require(
            store.owner() == address(this),
            "invalid store: store owner is not the factory contract"
        );
        stores[asset] = store;
    }

    function _getRegistryAsset(uint128 _asset) internal view returns (address) {
        address asset = registry.contracts(uint256(_asset));
        require(asset != address(0), "invalid asset: not registered");
        return asset;
    }
}
