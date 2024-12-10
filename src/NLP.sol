// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.19;

contract NLP {
    address constant NANI = 0x00000000000007C8612bA63Df8DdEfD9E6077c97; // token0
    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; // token1
    address constant DAO = 0xDa000000000000d2885F108500803dfBAaB2f2aA; // thedao
    address constant LP = 0x58Cf91C080F7052f6dA209BF605D6Cf1cefD65F3; // nanilp

    uint160 internal constant MAX_SQRT_RATIO_MINUS_ONE =
        1461446703485210103287273052203988822378723970341;

    constructor() payable {}

    function contribute() public payable {
        unchecked {
            IERC20(NANI).transfer(LP, msg.value / 0.00001 ether);
            ISwap(LP).swap(msg.sender, false, int256(msg.value), MAX_SQRT_RATIO_MINUS_ONE, "");
        }
    }

    function tribute() public payable {
        payable(DAO).transfer(address(this).balance);
    }

    fallback() external payable {
        assembly ("memory-safe") {
            let amount1Delta := calldataload(0x24)
            pop(call(gas(), WETH, amount1Delta, codesize(), 0x00, codesize(), 0x00))
            mstore(0x00, 0xa9059cbb000000000000000000000000)
            mstore(0x14, LP)
            mstore(0x34, amount1Delta)
            pop(call(gas(), WETH, 0, 0x10, 0x44, codesize(), 0x00))
        }
    }

    receive() external payable {
        contribute();
    }
}

interface IERC20 {
    function transfer(address, uint256) external returns (bool);
}

interface ISwap {
    function swap(address, bool, int256, uint160, bytes calldata)
        external
        returns (int256, int256);
}
