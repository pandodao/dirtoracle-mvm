// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.4 <0.9.0;

import {BytesLib} from "./Bytes.sol";
import {PBytesLib} from "./PBytes.sol";
import {BLS} from "./BLS.sol";
import "./FactoryInterface.sol";
import "./Ownable.sol";

contract DirtOracle is Ownable {
    using BytesLib for bytes;
    using PBytesLib for bytes;
    using BLS for uint256[2];
    using BLS for bytes;

    mapping(uint64 => mapping(uint64 => uint256[4])) public ORACLE_GROUP;
    uint64 public ORACLE_GROUP_VERSION = 0;
    FactoryInterface public factory;

    constructor() {
        _setupOracleGroups();
    }

    function refreshOracleGroupVersion() public onlyOwner {
        ORACLE_GROUP_VERSION = ORACLE_GROUP_VERSION + 1;
    }

    function setOracleGroup(uint64 mask, uint256[4] memory groups)
        public
        onlyOwner
    {
        ORACLE_GROUP[ORACLE_GROUP_VERSION][mask] = groups;
    }

    function transferFactory() public onlyOwner {
        factory.transferFactoryOwnership(msg.sender);
        factory = FactoryInterface(address(0x0));
    }

    function setFactory(address _factory) public onlyOwner {
        factory = FactoryInterface(_factory);
        require(
            factory.factoryOwner() == address(this),
            "invalid factory: owner is not current contract"
        );
    }

    function getAssetPriceStore(uint128 asset) public view returns (address) {
        return factory.getPriceStore(asset);
    }

    // process || nonce || asset || amount || extra || timestamp || members || threshold || sig
    function mixin(bytes calldata raw) public returns (bool) {
        require(raw.length >= 141, "event data too small");

        uint256 size = 0;
        uint256 offset = 40;
        size = raw.toUint16(offset);
        require(size <= 32, "integer out of bounds");
        offset = offset + 2 + size;

        size = raw.toUint16(offset);
        offset = offset + 2;
        bytes memory extra = raw.slice(offset, size);
        return updatePriceWithMemo(extra);
    }

    function updatePriceWithMemo(bytes memory data) public returns (bool) {
        uint256 offset = 0;

        require(
            data.length >= 65 || data.length <= 162,
            "invalid extra length"
        );

        uint8 size = data.toUint8(offset);
        require(size < 8, "invalid timestamp size");
        offset += 1;

        uint64 timestamp = uint64(data.toInt64(offset, size));
        offset += size;

        require(data.toUint8(offset) == 16, "invalid asset");
        offset += 1;

        uint128 asset = data.toUint128(offset);
        offset += 16;

        size = data.toUint8(offset);
        require(size >= 4 && size <= 37, "invalid price");
        offset += 1;

        uint256 priceValue;
        int32 priceExp;
        bool priceSign;
        (priceSign, priceExp, priceValue) = data.toDecimal(offset, size);
        offset += size;
        require(!priceSign, "price not positive");

        uint256[2] memory message = data.slice(0, offset).hashToPoint();

        size = data.toUint8(offset);
        require(size == 36 || size == 97, "invalid cosi-signature");
        offset += 1;

        size = data.toUint8(offset);
        require(size > 0 && size <= 8, "invalid signature mask size");
        offset += 1;

        uint64 mask = data.toUint64(offset, size);
        offset += 1;

        uint256[4] memory pubkey = ORACLE_GROUP[ORACLE_GROUP_VERSION][mask];
        require(pubkey[0] != 0, "invalid signature");

        size = data.toUint8(offset);
        require(size == 33 || size == 64, "invalid signature mask");
        offset += 1;

        uint256[2] memory sig = data.toSignature(offset, size);
        offset += size;

        require(sig.verifySingle(pubkey, message), "invalid price signature");
        factory.addAssetPrice(asset, timestamp, priceValue, priceExp);
        return true;
    }

    function _setupOracleGroups() internal {
        setOracleGroup(
            30,
            [
                0x1fc720dc516be0accd3c69225409dbe4c942932e8d7412dd5626503a013cca41,
                0x092a11f3dc9884b667257d7665d54589484c2a8011d89dc75558e060125bf957,
                0x13cb14f607a875902f8211076b7921ee896e3117a19b23e41e0b14bcbf581634,
                0x2606279c6d107ff157b0821ac06ad1306eed70ca5fa912b7753514d422aa90fe
            ]
        );
        setOracleGroup(
            46,
            [
                0x1169aa5c87f364dd327b5473d2890ea4470f937bd73886f2603c9bdfcf1fd93a,
                0x19308555933166b914882174b919491a59475aac62e2ad375c3b021144dc5bf5,
                0x2eb4af7cf82c51d5d50a671b4bbf5691dbf652ac3cc4173d9bf6a865e95e88ef,
                0x02fe06677f60708229b3a202fea4ce1fb8f4b7cf94c5c8cbe9f3e01f44dfc055
            ]
        );
        setOracleGroup(
            54,
            [
                0x0b7ad45bf0feee296943135fadca64cccbe56d4c953b2705cce85610684d9760,
                0x04e440c436c10a23300df8853531eede316ae2ffecdcaaf9a08e9bb03b591930,
                0x08e81a6032ee126d44cb2cb5c4eeddd668f272025e73abfbcc559141872aa258,
                0x18775110a38c3f307f67fe43fe7aedd00cc2f0060a560a4ef34805689b7ea7b9
            ]
        );
        setOracleGroup(
            58,
            [
                0x25b908e3a44591fb55128a7ad6e3174905603eef084776531cfac39fe1eed745,
                0x0309de4a193c93ab1f6abac1c74f47f519ace9119f6b48d42849c5945a36c8a7,
                0x028cace7c41c4a3874b8d502082459e3357bdf9bc91f0d24a3405a7cf745ea66,
                0x1c58bd6368a4c639e4193c3ff70e761108db15d125ec89291264606f04d1e772
            ]
        );
        setOracleGroup(
            60,
            [
                0x261bfd51a1cb4ee3a43e517207a8e04fbc4a86aa8bdf3764746bae6d8d7a35b2,
                0x0fceaca6d27aded4fbb9c84b65791414ccf86017d8ffadb565084e8fef4b5a83,
                0x1bd845c3078c31b601110cd47d2452534cac6a6a06dbe86d91e480e97f0c2b92,
                0x2414d3cd18e4dc0021312629bdee039423359e71cfdf1b5ab235c7829e1f05fa
            ]
        );
        setOracleGroup(
            78,
            [
                0x0a145142d527d9d3162d1e9330ff2743cee8105b11a3826b7884a73b47e06b5b,
                0x0b9f1bf069c73695fae78ac360a3d7391e2857b956939abcaef0bbd34ecbe29b,
                0x09f1a1d08c43070b7bc4d7968ac80cafe73ef03229871cd22a74c75fc203c957,
                0x22387369a0e1eee0823d99bbbdeee6a3dbbc31a2f9d4258bf18106c14340b29a
            ]
        );
        setOracleGroup(
            86,
            [
                0x2cf4db4da9d93b21446aadacd0fec48f64254d009bf9382d151e5fe53ab4591e,
                0x0b85853dc1db16cba5e6947c0cf3e37c10923aa0349468155cd2e295646421de,
                0x142f8252108651f4e9cae9060b27c856e2af659b1b353e0928d00c8c5044fd41,
                0x1f51b109a2e3f80078a6e926e50b295210bf10a6dfeb89cd3ab915a32d4fb57e
            ]
        );
        setOracleGroup(
            90,
            [
                0x16b273470d50ef63d0ad55d6d720ba3f4249652a0b30a79fedcd1f8c19411f06,
                0x0d148478d7bdfc60141b0557ab6dfd217cf7ff413dd418581435e86bea5a750c,
                0x116d4e45bca52d0eb90273316ceb12753867b7727827f5c99bccb150fdced823,
                0x1fadffdf4d3b549f8bd5fd2d45bcf5973ecde048a876000b063adf6b9bd84303
            ]
        );
        setOracleGroup(
            92,
            [
                0x0e4ff81436b310506659b56bf789da2cc51d5175a4f9397406f17f79cee8bc8b,
                0x1d9aec084e2c544720f185245f0c1456ec9acb89b0bbb2fd2cf1069b02a9fdea,
                0x05200029739173591bb70f1dda1ad5e02e52f20e031bf17612ac19d526867f64,
                0x18fbb5c2275bad8a8addacd93c03b0e0e1dd888f5f5c716d96c4cffac35b68a3
            ]
        );
        setOracleGroup(
            102,
            [
                0x14fe88d94a8d9de4aecb510e129835b9a684bae21f8f9893f8dfcf5b0c3f8545,
                0x10c79d83b36eed62907b14506744abba7a41903678996d5ad893562277e55c6d,
                0x185ab32e65207dd88927948d7f4d0647dc722a8a83248e2d4cdce4b695a65be1,
                0x13a2220ebdfc20436035b7f56ede12cda6b76d5d728bdcc26217ed3161fab0fe
            ]
        );
        setOracleGroup(
            106,
            [
                0x21e654bd23617e32a2a1e87f79acd84e91c99baab2651952e43af399b12ac76a,
                0x046273dd0b2ed8b0f0b36f94fdcb3296e15564a8837d353fa0c4e66ab1428aea,
                0x04aa980bc850d1f32e4e59e12a88bf5e4f319dd85d3f81b832b29325b4ab46ae,
                0x069c59d0e6e4b06666f6fb1677c78a3dcab641ad31482fa65651953f4b1d3a70
            ]
        );
        setOracleGroup(
            108,
            [
                0x127ca28c4b72e8b1274a9af7c650ab1ea9fa130f591de3f132a02d1cc1d9ad25,
                0x0e3954e30221d8c23d740e144e27b0c2acd294071bfaeca600ff916ff88a2659,
                0x218caaa4367a0afb19371e0dd880fc67f39f149963bb5977932ab20381deb05e,
                0x23244b6312e7b8c340d29eb86412c78ccf93300786b2413a1ee837a098cacdf5
            ]
        );
        setOracleGroup(
            114,
            [
                0x06a8bfbf225ab80156d7970f7bc104b41df75e25721c6d3a9cbf94cd37d79f92,
                0x1c7fcf54cd4e0386951afb83aa1c7a789c9abfdb480842cae5b06f7e4960521e,
                0x01b63095c2ed7acecd4eb5ddbb32c28c9ff923007abd4ab8b8b1b6d5b9a15ddb,
                0x2aa17c9c92a2e37b6dfe3bcefcca9daae48f4167b4c30fa0a5710b155532302d
            ]
        );
        setOracleGroup(
            116,
            [
                0x2d710dfb71f8ce6b895b7768f0d85e129dcb7ec0b24b045e410782a4054cb306,
                0x1b30389528bb49de1c7f57df01064f7fb2467de8037d2aea18baa70f82591de1,
                0x2c19c04b465ac91565f4903db596b6b14858e331981e5d206086c5c39feab65d,
                0x26c60e5f455690bec6b1bc84b9eda1b53ca9cab4cf586a26a39421b8314de59f
            ]
        );
        setOracleGroup(
            120,
            [
                0x112f16bc447e26f8249e4a74aeb7329b65ec99b6657b8bfdccf18cbc14aa481b,
                0x04739705313808b7020c717b40e4cd3ef8a210d3a95eaf6e56bb0dbf04871900,
                0x1cce32d469ce57c3a8b826e14b55001a83a3884e6b171f763701a00bc45545de,
                0x00b09742ef09899cda26b11a6974ea6a01116f75b6378ee790723604dfa6b5da
            ]
        );
    }
}
