// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "./Ownable.sol";
import "./AggregatorV3Interface.sol";

contract PriceStoreV3 is Ownable, AggregatorV3Interface {
    event AnswerUpdated(
        int256 indexed current,
        uint256 indexed roundId,
        uint256 updatedAt
    );
    event NewRound(
        uint256 indexed roundId,
        address indexed startedBy,
        uint256 startedAt
    );
    struct PriceData {
        uint80 roundId;
        int256 answer;
        uint256 startedAt;
        uint256 updatedAt;
        uint80 answeredInRound;
    }

    address public asset;
    uint80 public latestRoundId;
    string public override description;
    uint8 public override decimals = 8;
    uint256 public override version;

    mapping(uint80 => PriceData) public prices;

    constructor(address _asset) {
        asset = _asset;
    }

    function setDecimals(uint8 _dec) public onlyOwner {
        decimals = _dec;
    }

    function setDescription(string memory _desc) public onlyOwner {
        description = _desc;
    }

    function addNewAnswer(uint256 timestamp, int256 answer)
        public
        onlyOwner
        returns (uint80)
    {
        require(answer > 0, "price not positive");
        require(timestamp > prices[latestRoundId].startedAt, "price outdated");

        latestRoundId++;
        PriceData memory price;
        price.roundId = latestRoundId;
        price.answeredInRound = latestRoundId;
        price.startedAt = timestamp;
        price.updatedAt = block.timestamp;
        price.answer = answer;
        prices[latestRoundId] = price;
        emit NewRound(latestRoundId, msg.sender, timestamp);
        emit AnswerUpdated(answer, latestRoundId, price.updatedAt);
        return latestRoundId;
    }

    function getRoundData(uint80 _roundId)
        external
        view
        override
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        )
    {
        return _getRoundData(_roundId);
    }

    function latestRoundData()
        external
        view
        override
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        )
    {
        return _getRoundData(latestRoundId);
    }

    function _getRoundData(uint80 _roundId)
        internal
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        )
    {
        PriceData memory price = prices[_roundId];
        return (
            _roundId,
            price.answer,
            price.startedAt,
            price.updatedAt,
            _roundId
        );
    }
}
