// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.19;

/// @notice NANI LP
contract NLP {
    address constant NANI = 0x00000000000007C8612bA63Df8DdEfD9E6077c97;
    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address constant DAO = 0xDa000000000000d2885F108500803dfBAaB2f2aA;
    address constant LP = 0x58Cf91C080F7052f6dA209BF605D6Cf1cefD65F3;
    address constant POS_MNGR = 0xC36442b4a4522E871399CD717aBDD847Ab11FE88;

    uint160 constant MAX_SQRT_RATIO_MINUS_ONE = 1461446703485210103287273052203988822378723970341;
    int24 constant TICK_SPACING = 60; // 0.3% pool.

    uint256 constant MIN_DISCOUNT = 80; // 80% of market price.
    uint256 constant MAX_DISCOUNT = 95; // 95% of market price.
    uint256 constant TWO_192 = 2 ** 192;

    constructor() payable {
        IERC20(NANI).approve(POS_MNGR, type(uint256).max);
        IERC20(WETH).approve(POS_MNGR, type(uint256).max);
    }

    function contribute() public payable {
        unchecked {
            assembly ("memory-safe") {
                pop(call(gas(), WETH, callvalue(), codesize(), 0x00, codesize(), 0x00))
            }

            uint256 random = _random();
            if (random % 2 == 0) {
                (uint160 sqrtPriceX96, int24 currentTick,,,,,) = IUniswapV3Pool(LP).slot0();

                // Calculate discounted NANI amount for LP position:
                uint256 naniForLP = (msg.value * TWO_192)
                    / (uint256(sqrtPriceX96) * uint256(sqrtPriceX96)) * 100 / _hem(random, MIN_DISCOUNT, MAX_DISCOUNT);

                INonfungiblePositionManager.MintParams memory params = INonfungiblePositionManager
                    .MintParams({
                    token0: NANI,
                    token1: WETH,
                    fee: 3000,
                    tickLower: (currentTick - 600) / 60 * 60,
                    tickUpper: (currentTick + 600) / 60 * 60,
                    amount0Desired: naniForLP,
                    amount1Desired: 0,
                    amount0Min: 0,
                    amount1Min: 0,
                    recipient: msg.sender,
                    deadline: block.timestamp
                });

                INonfungiblePositionManager(POS_MNGR).mint(params);
            }
            
            IUniswapV3Pool(LP).swap(
                msg.sender,
                false,
                int256(msg.value),
                MAX_SQRT_RATIO_MINUS_ONE,
                ""
            );
        }
    }

    function contributeFullRange() public payable {
        unchecked {
            assembly ("memory-safe") {
                pop(call(gas(), WETH, callvalue(), codesize(), 0x00, codesize(), 0x00))
            }

            uint256 random = _random();
            if (random % 2 == 0) {
            (uint160 sqrtPriceX96,,,,,,) = IUniswapV3Pool(LP).slot0();

            // Calculate discounted NANI amount for LP position:
            uint256 naniForLP = (msg.value * TWO_192)
                / (uint256(sqrtPriceX96) * uint256(sqrtPriceX96)) * 100 / _hem(random, MIN_DISCOUNT, MAX_DISCOUNT);

            INonfungiblePositionManager.MintParams memory params = INonfungiblePositionManager
                .MintParams({
                token0: NANI,
                token1: WETH,
                fee: 3000,
                tickLower: -887220,
                tickUpper: 887220,
                amount0Desired: naniForLP,
                amount1Desired: 0,
                amount0Min: 0,
                amount1Min: 0,
                recipient: msg.sender,
                deadline: block.timestamp
            });

                INonfungiblePositionManager(POS_MNGR).mint(params);
            }

            IUniswapV3Pool(LP).swap(
                msg.sender,
                false,
                int256(msg.value),
                MAX_SQRT_RATIO_MINUS_ONE,
                ""
            );
        }
    }

    function tribute() public payable {
        payable(DAO).transfer(address(this).balance);
    }

    function withdraw(uint256 amount) public payable {
        require(msg.sender == DAO);
        IERC20(NANI).transfer(DAO, amount);
    }

    /// @dev Returns a pseudorandom random number from [0 .. 2**256 - 1] (inclusive).
    /// For usage in fuzz tests, please ensure that the function has an unnamed uint256 argument.
    /// e.g. `testSomething(uint256) public`.
    function _random() internal returns (uint256 r) {
        /// @solidity memory-safe-assembly
        assembly {
            // This is the keccak256 of a very long string I randomly mashed on my keyboard.
            let sSlot := 0xd715531fe383f818c5f158c342925dcf01b954d24678ada4d07c36af0f20e1ee
            let sValue := sload(sSlot)

            mstore(0x20, sValue)
            r := keccak256(0x20, 0x40)

            // If the storage is uninitialized, initialize it to the keccak256 of the calldata.
            if iszero(sValue) {
                sValue := sSlot
                let m := mload(0x40)
                calldatacopy(m, 0, calldatasize())
                r := keccak256(m, calldatasize())
            }
            sstore(sSlot, add(r, 1))

            // Do some biased sampling for more robust tests.
            // prettier-ignore
            for {} 1 {} {
                let d := byte(0, r)
                // With a 1/256 chance, randomly set `r` to any of 0,1,2.
                if iszero(d) {
                    r := and(r, 3)
                    break
                }
                // With a 1/2 chance, set `r` to near a random power of 2.
                if iszero(and(2, d)) {
                    // Set `t` either `not(0)` or `xor(sValue, r)`.
                    let t := xor(not(0), mul(iszero(and(4, d)), not(xor(sValue, r))))
                    // Set `r` to `t` shifted left or right by a random multiple of 8.
                    switch and(8, d)
                    case 0 {
                        if iszero(and(16, d)) { t := 1 }
                        r := add(shl(shl(3, and(byte(3, r), 0x1f)), t), sub(and(r, 7), 3))
                    }
                    default {
                        if iszero(and(16, d)) { t := shl(255, 1) }
                        r := add(shr(shl(3, and(byte(3, r), 0x1f)), t), sub(and(r, 7), 3))
                    }
                    // With a 1/2 chance, negate `r`.
                    if iszero(and(0x20, d)) { r := not(r) }
                    break
                }
                // Otherwise, just set `r` to `xor(sValue, r)`.
                r := xor(sValue, r)
                break
            }
        }
    }

    function _hem(uint256 x, uint256 min, uint256 max)
        internal
        pure
        
        returns (uint256 result)
    {
        require(min <= max, "Max is less than min.");

        /// @solidity memory-safe-assembly
        assembly {
            // prettier-ignore
            for {} 1 {} {
                // If `x` is between `min` and `max`, return `x` directly.
                // This is to ensure that dictionary values
                // do not get shifted if the min is nonzero.
                // More info: https://github.com/foundry-rs/forge-std/issues/188
                if iszero(or(lt(x, min), gt(x, max))) {
                    result := x
                    break
                }

                let size := add(sub(max, min), 1)
                if and(iszero(gt(x, 3)), gt(size, x)) {
                    result := add(min, x)
                    break
                }

                let w := not(0)
                if and(iszero(lt(x, sub(0, 4))), gt(size, sub(w, x))) {
                    result := sub(max, sub(w, x))
                    break
                }

                // Otherwise, wrap x into the range [min, max],
                // i.e. the range is inclusive.
                if iszero(lt(x, max)) {
                    let d := sub(x, max)
                    let r := mod(d, size)
                    if iszero(r) {
                        result := max
                        break
                    }
                    result := add(add(min, r), w)
                    break
                }
                let d := sub(min, x)
                let r := mod(d, size)
                if iszero(r) {
                    result := min
                    break
                }
                result := add(sub(max, r), 1)
                break
            }
        }
    }

    fallback() external payable {
        assembly ("memory-safe") {
            let amount1Delta := calldataload(0x24)
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
    function approve(address spender, uint256 amount) external returns (bool);
}

interface INonfungiblePositionManager {
    struct MintParams {
        address token0;
        address token1;
        uint24 fee;
        int24 tickLower;
        int24 tickUpper;
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 amount0Min;
        uint256 amount1Min;
        address recipient;
        uint256 deadline;
    }

    function mint(MintParams calldata params)
        external
        payable
        returns (uint256 tokenId, uint128 liquidity, uint256 amount0, uint256 amount1);
}

interface IUniswapV3Pool {
    function slot0()
        external
        view
        returns (
            uint160 sqrtPriceX96,
            int24 tick,
            uint16 observationIndex,
            uint16 observationCardinality,
            uint16 observationCardinalityNext,
            uint8 feeProtocol,
            bool unlocked
        );

    function swap(
        address recipient,
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96,
        bytes calldata data
    ) external returns (int256 amount0, int256 amount1);
}
