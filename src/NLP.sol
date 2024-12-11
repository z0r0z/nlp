// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.19;

contract NLP {
    address constant NANI = 0x00000000000007C8612bA63Df8DdEfD9E6077c97;
    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    address constant LP = 0x58Cf91C080F7052f6dA209BF605D6Cf1cefD65F3;
    address constant POS_MNGR = 0xC36442b4a4522E871399CD717aBDD847Ab11FE88;

    uint160 constant MAX_SQRT_RATIO_MINUS_ONE = 1461446703485210103287273052203988822378723970341;
    int24 constant TICK_SPACING = 60;

    uint256 private constant TWO_192 = 2 ** 192;

    constructor() payable {
        IERC20(NANI).approve(POS_MNGR, type(uint256).max);
        IERC20(WETH).approve(POS_MNGR, type(uint256).max);
    }

    function contribute() public payable {
        unchecked {
            uint256 liquidityPortion = msg.value / 5;

            (uint160 sqrtPriceX96, int24 currentTick,,,,,) = IUniswapV3Pool(LP).slot0();

            assembly ("memory-safe") {
                pop(call(gas(), WETH, liquidityPortion, codesize(), 0x00, codesize(), 0x00))
            }

            INonfungiblePositionManager.MintParams memory params = INonfungiblePositionManager
                .MintParams({
                token0: NANI,
                token1: WETH,
                fee: 3000,
                tickLower: (currentTick - 600) / 60 * 60,
                tickUpper: (currentTick + 600) / 60 * 60,
                amount0Desired: (liquidityPortion * TWO_192)
                    / (uint256(sqrtPriceX96) * uint256(sqrtPriceX96)),
                amount1Desired: liquidityPortion,
                amount0Min: 0,
                amount1Min: 0,
                recipient: msg.sender,
                deadline: block.timestamp
            });

            INonfungiblePositionManager(POS_MNGR).mint(params);
            IUniswapV3Pool(LP).swap(
                msg.sender,
                false,
                int256(msg.value - liquidityPortion),
                MAX_SQRT_RATIO_MINUS_ONE,
                ""
            );
        }
    }

    function contributeFullRange() public payable {
        unchecked {
            uint256 liquidityPortion = msg.value / 5;

            (uint160 sqrtPriceX96,,,,,,) = IUniswapV3Pool(LP).slot0();

            assembly ("memory-safe") {
                pop(call(gas(), WETH, liquidityPortion, codesize(), 0x00, codesize(), 0x00))
            }

            INonfungiblePositionManager.MintParams memory params = INonfungiblePositionManager
                .MintParams({
                token0: NANI,
                token1: WETH,
                fee: 3000,
                tickLower: -887220,
                tickUpper: 887220,
                amount0Desired: (liquidityPortion * TWO_192)
                    / (uint256(sqrtPriceX96) * uint256(sqrtPriceX96)),
                amount1Desired: liquidityPortion,
                amount0Min: 0,
                amount1Min: 0,
                recipient: msg.sender,
                deadline: block.timestamp
            });

            INonfungiblePositionManager(POS_MNGR).mint(params);
            IUniswapV3Pool(LP).swap(
                msg.sender,
                false,
                int256(msg.value - liquidityPortion),
                MAX_SQRT_RATIO_MINUS_ONE,
                ""
            );
        }
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
