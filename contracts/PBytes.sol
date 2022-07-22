// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4 <0.9.0;

import {BytesLib} from "./Bytes.sol";
import {BLS} from "./BLS.sol";

library PBytesLib {
    using BytesLib for bytes;
    using BLS for uint256;
    using BLS for uint256[2];

    function toInt64(
        bytes memory data,
        uint256 offset,
        uint8 size
    ) internal pure returns (int64) {
        uint64 ux = toUint64(data, offset, size);
        int64 x = int64(ux >> 1);
        if (ux & 1 != 0) {
            x = ~x;
        }
        return x;
    }

    function toUint64(
        bytes memory data,
        uint256 offset,
        uint8 size
    ) internal pure returns (uint64) {
        uint64 x;
        uint64 s;
        for (uint256 i = offset; i < offset + size; i++) {
            uint8 b = data.toUint8(i);
            if (b < 0x80) {
                require(i != 10 || b < 1, "uint64 value overflow");
                return x | (uint64(b) << s);
            }
            x = x | ((uint64(b & 0x7f)) << s);
            s += 7;
        }
        return 0;
    }

    function toDecimal(
        bytes memory data,
        uint256 offset,
        uint8 size
    )
        internal
        pure
        returns (
            bool,
            int32,
            uint256
        )
    {
        int32 exp = data.toInt32(offset);
        offset += 4;

        if (size == 4) {
            return (true, exp, 0);
        }

        bool sign = (data.toUint8(offset) & 1) != 0;
        offset += 1;

        uint256 value = new bytes(32 - (size - 5))
            .concat(data.slice(offset, size - 5))
            .toUint256(0);

        return (sign, exp, value);
    }

    function toSignature(
        bytes memory data,
        uint256 offset,
        uint8 size
    ) internal view returns (uint256[2] memory) {
        uint256[2] memory sig;
        sig[0] = data.toUint256(offset);
        offset += 32;
        if (size == 64) {
            sig[1] = data.toUint256(offset + 32);
            offset += 32;
        } else {
            sig[1] = sig[0].sigToUncompresed(data.toUint8(offset));
            offset += 1;
        }

        require(sig.isValidSignature(), "invalid signature");
        return sig;
    }
}
