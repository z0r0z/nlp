// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.19;

import {NLP, IUniswapV3Pool} from "../src/NLP.sol";
import {NSFW} from "../src/NSFW.sol";
import {NaNs} from "../src/NaNs.sol";
import {Test} from "../lib/forge-std/src/Test.sol";
import {console} from "forge-std/console.sol";

contract NLPTest is Test {
    NLP internal nlp;
    NSFW internal nsfw;
    NaNs internal nans;

    address constant NANI = 0x00000000000007C8612bA63Df8DdEfD9E6077c97;
    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address constant DAO = 0xDa000000000000d2885F108500803dfBAaB2f2aA;
    address constant LP = 0x58Cf91C080F7052f6dA209BF605D6Cf1cefD65F3;

    address constant V = 0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045;
    address constant A = 0x0000000000001d8a2e7bf6bc369525A2654aa298;
    address constant CTC = 0x0000000000cDC1F8d393415455E382c30FBc0a84;

    uint160 constant MAX_SQRT_RATIO_MINUS_ONE = 1461446703485210103287273052203988822378723970341;

    uint160 internal constant MIN_SQRT_RATIO_PLUS_ONE = 4295128740;

    address deployer;

    function setUp() public payable {
        uint256 deployerPrivateKey =
            0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
        deployer = vm.addr(deployerPrivateKey);

        vm.startPrank(deployer);
        vm.createSelectFork(vm.rpcUrl("main"));
        nlp = new NLP();
        nsfw = new NSFW();
        nans = new NaNs();
        vm.stopPrank();

        vm.prank(A);
        IERC20(NANI).transfer(address(nlp), 10_000_000 ether);
        require(IERC20(NANI).balanceOf(address(nlp)) == 10_000_000 ether, "NLP not funded properly");
    }

    function testNormalSwapLowAmt() public payable {
        uint256 bal = IERC20(NANI).balanceOf(V);
        console.log(bal, "/vb starting bal");
        uint256 nBal = IERC20(NANI).balanceOf(address(LP));
        uint256 wBal = IERC20(WETH).balanceOf(address(LP));
        console.log(nBal, "/lp starting nani bal");
        console.log(wBal, "/lp starting weth bal");
        (uint256 price, string memory strPrice) = ICTC(CTC).checkPriceInETH(NANI);
        (uint256 priceUSDC, string memory strPriceUSDC) = ICTC(CTC).checkPriceInETHToUSDC(NANI);
        console.log(price, "/starting price in raw ETH");
        console.log(strPrice, "/starting price in ETH");
        console.log(priceUSDC, "/starting price in raw USDC");
        console.log(strPriceUSDC, "/starting price in USDC");

        vm.prank(V);
        nsfw.swap{value: 0.015 ether}(V, 0);

        (price, strPrice) = ICTC(CTC).checkPriceInETH(NANI);
        (priceUSDC, strPriceUSDC) = ICTC(CTC).checkPriceInETHToUSDC(NANI);
        console.log(price, "/resulting price in raw ETH");
        console.log(strPrice, "/resulting price in ETH");
        console.log(priceUSDC, "/resulting price in raw USDC");
        console.log(strPriceUSDC, "/resulting price in USDC");
        bal = IERC20(NANI).balanceOf(V);
        console.log(bal, "/vb resulting bal");
        nBal = IERC20(NANI).balanceOf(address(LP));
        wBal = IERC20(WETH).balanceOf(address(LP));
        console.log(nBal, "/lp resulting nani bal");
        console.log(wBal, "/lp resulting weth bal");
    }

    function testNormalSwapHiAmt() public payable {
        uint256 bal = IERC20(NANI).balanceOf(V);
        console.log(bal, "/vb starting bal");
        uint256 nBal = IERC20(NANI).balanceOf(address(LP));
        uint256 wBal = IERC20(WETH).balanceOf(address(LP));
        console.log(nBal, "/lp starting nani bal");
        console.log(wBal, "/lp starting weth bal");
        (uint256 price, string memory strPrice) = ICTC(CTC).checkPriceInETH(NANI);
        (uint256 priceUSDC, string memory strPriceUSDC) = ICTC(CTC).checkPriceInETHToUSDC(NANI);
        console.log(price, "/starting price in raw ETH");
        console.log(strPrice, "/starting price in ETH");
        console.log(priceUSDC, "/starting price in raw USDC");
        console.log(strPriceUSDC, "/starting price in USDC");

        vm.prank(V);
        nsfw.swap{value: 10 ether}(V, 0);

        (price, strPrice) = ICTC(CTC).checkPriceInETH(NANI);
        (priceUSDC, strPriceUSDC) = ICTC(CTC).checkPriceInETHToUSDC(NANI);
        console.log(price, "/resulting price in raw ETH");
        console.log(strPrice, "/resulting price in ETH");
        console.log(priceUSDC, "/resulting price in raw USDC");
        console.log(strPriceUSDC, "/resulting price in USDC");
        bal = IERC20(NANI).balanceOf(V);
        console.log(bal, "/vb resulting bal");
        nBal = IERC20(NANI).balanceOf(address(LP));
        wBal = IERC20(WETH).balanceOf(address(LP));
        console.log(nBal, "/lp resulting nani bal");
        console.log(wBal, "/lp resulting weth bal");
    }

    function testContributeLowAmt() public payable {
        uint256 bal = IERC20(NANI).balanceOf(V);
        console.log(bal, "/vb starting bal");
        uint256 nBal = IERC20(NANI).balanceOf(address(LP));
        uint256 wBal = IERC20(WETH).balanceOf(address(LP));
        console.log(nBal, "/lp starting nani bal");
        console.log(wBal, "/lp starting weth bal");
        (uint256 price, string memory strPrice) = ICTC(CTC).checkPriceInETH(NANI);
        (uint256 priceUSDC, string memory strPriceUSDC) = ICTC(CTC).checkPriceInETHToUSDC(NANI);
        console.log(price, "/starting price in raw ETH");
        console.log(strPrice, "/starting price in ETH");
        console.log(priceUSDC, "/starting price in raw USDC");
        console.log(strPriceUSDC, "/starting price in USDC");

        vm.prank(V);
        nlp.contribute{value: 0.015 ether}();

        (price, strPrice) = ICTC(CTC).checkPriceInETH(NANI);
        (priceUSDC, strPriceUSDC) = ICTC(CTC).checkPriceInETHToUSDC(NANI);
        console.log(price, "/resulting price in raw ETH");
        console.log(strPrice, "/resulting price in ETH");
        console.log(priceUSDC, "/resulting price in raw USDC");
        console.log(strPriceUSDC, "/resulting price in USDC");
        bal = IERC20(NANI).balanceOf(V);
        console.log(bal, "/vb resulting bal");
        console.log(address(nlp).balance, "/dao ETH");
        nBal = IERC20(NANI).balanceOf(address(LP));
        wBal = IERC20(WETH).balanceOf(address(LP));
        console.log(nBal, "/lp resulting nani bal");
        console.log(wBal, "/lp resulting weth bal");
    }

    function testContributeHiAmt() public payable {
        uint256 bal = IERC20(NANI).balanceOf(V);
        console.log(bal, "/vb starting bal");
        uint256 nBal = IERC20(NANI).balanceOf(address(LP));
        uint256 wBal = IERC20(WETH).balanceOf(address(LP));
        console.log(nBal, "/lp starting nani bal");
        console.log(wBal, "/lp starting weth bal");
        (uint256 price, string memory strPrice) = ICTC(CTC).checkPriceInETH(NANI);
        (uint256 priceUSDC, string memory strPriceUSDC) = ICTC(CTC).checkPriceInETHToUSDC(NANI);
        console.log(price, "/starting price in raw ETH");
        console.log(strPrice, "/starting price in ETH");
        console.log(priceUSDC, "/starting price in raw USDC");
        console.log(strPriceUSDC, "/starting price in USDC");

        vm.prank(V);
        nlp.contribute{value: 10 ether}();

        (price, strPrice) = ICTC(CTC).checkPriceInETH(NANI);
        (priceUSDC, strPriceUSDC) = ICTC(CTC).checkPriceInETHToUSDC(NANI);
        console.log(price, "/resulting price in raw ETH");
        console.log(strPrice, "/resulting price in ETH");
        console.log(priceUSDC, "/resulting price in raw USDC");
        console.log(strPriceUSDC, "/resulting price in USDC");
        bal = IERC20(NANI).balanceOf(V);
        console.log(bal, "/vb resulting bal");
        console.log(address(nlp).balance, "/dao ETH");
        nBal = IERC20(NANI).balanceOf(address(LP));
        wBal = IERC20(WETH).balanceOf(address(LP));
        console.log(nBal, "/lp resulting nani bal");
        console.log(wBal, "/lp resulting weth bal");
    }

    function testContributeAndCheckPrice() public payable {
        uint256 bal = IERC20(NANI).balanceOf(V);
        console.log(bal, "/vb starting bal");
        uint256 nBal = IERC20(NANI).balanceOf(address(LP));
        uint256 wBal = IERC20(WETH).balanceOf(address(LP));
        console.log(nBal, "/lp starting nani bal");
        console.log(wBal, "/lp starting weth bal");
        (uint256 price, string memory strPrice) = ICTC(CTC).checkPriceInETH(NANI);
        (uint256 priceUSDC, string memory strPriceUSDC) = ICTC(CTC).checkPriceInETHToUSDC(NANI);
        console.log(price, "/starting price in raw ETH");
        console.log(strPrice, "/starting price in ETH");
        console.log(priceUSDC, "/starting price in raw USDC");
        console.log(strPriceUSDC, "/starting price in USDC");
        vm.prank(V);
        nlp.contribute{value: 0.015 ether}();
        (price, strPrice) = ICTC(CTC).checkPriceInETH(NANI);
        (priceUSDC, strPriceUSDC) = ICTC(CTC).checkPriceInETHToUSDC(NANI);
        console.log(price, "/resulting price in raw ETH");
        console.log(strPrice, "/resulting price in ETH");
        console.log(priceUSDC, "/resulting price in raw USDC");
        console.log(strPriceUSDC, "/resulting price in USDC");
        bal = IERC20(NANI).balanceOf(V);
        console.log(bal, "/vb resulting bal");
        console.log(address(nlp).balance, "/dao ETH");
        nBal = IERC20(NANI).balanceOf(address(LP));
        wBal = IERC20(WETH).balanceOf(address(LP));
        console.log(nBal, "/lp resulting nani bal");
        console.log(wBal, "/lp resulting weth bal");
    }

    function testContributeWithTimestamps() public {
        uint256[] memory timestamps = new uint256[](5);
        timestamps[0] = block.timestamp;
        timestamps[1] = block.timestamp + 1 days;
        timestamps[2] = block.timestamp + 1 weeks;
        timestamps[3] = block.timestamp + 4 weeks;
        timestamps[4] = block.timestamp + 365 days;

        uint256 amount = 1 ether; // Fixed amount for consistency

        for (uint256 i = 0; i < timestamps.length; i++) {
            console.log("\n=== Test Case", i + 1, "===");
            console.log("Timestamp:", timestamps[i]);
            console.log("Amount:", amount);

            vm.warp(timestamps[i]);

            uint256 startLPNani = IERC20(NANI).balanceOf(address(LP));
            uint256 startLPWeth = IERC20(WETH).balanceOf(address(LP));
            uint256 startUserNani = IERC20(NANI).balanceOf(V);

            console.log("\nStarting Balances:");
            console.log("LP NANI Balance:", startLPNani);
            console.log("LP WETH Balance:", startLPWeth);
            console.log("User NANI Balance:", startUserNani);

            (, string memory startPriceStr) = ICTC(CTC).checkPriceInETH(NANI);
            (, string memory startPriceUSDCStr) = ICTC(CTC).checkPriceInETHToUSDC(NANI);

            console.log("\nStarting Prices:");
            console.log("ETH Price:", startPriceStr);
            console.log("USDC Price:", startPriceUSDCStr);

            vm.prank(V);
            nlp.contribute{value: amount}();

            uint256 endLPNani = IERC20(NANI).balanceOf(address(LP));
            uint256 endLPWeth = IERC20(WETH).balanceOf(address(LP));
            uint256 endUserNani = IERC20(NANI).balanceOf(V);

            console.log("\nEnding Balances:");
            console.log("LP NANI Balance:", endLPNani);
            console.log("LP WETH Balance:", endLPWeth);
            console.log("User NANI Balance:", endUserNani);

            (, string memory endPriceStr) = ICTC(CTC).checkPriceInETH(NANI);
            (, string memory endPriceUSDCStr) = ICTC(CTC).checkPriceInETHToUSDC(NANI);

            console.log("\nEnding Prices:");
            console.log("ETH Price:", endPriceStr);
            console.log("USDC Price:", endPriceUSDCStr);

            bool isLPCreated = endLPNani > startLPNani && endLPWeth > startLPWeth;

            console.log("\nTransaction Result:");
            if (isLPCreated) {
                console.log("Lottery Won - LP Position Created");
                console.log("NANI Added to LP:", endLPNani - startLPNani);
                console.log("WETH Added to LP:", endLPWeth - startLPWeth);
            } else {
                console.log("Direct Swap Performed");
                console.log("NANI Received:", endUserNani - startUserNani);
            }

            // Reset state for next test
            vm.roll(block.number + 1);
        }
    }

    function testContributeAndSellWithTimestamps() public {
        uint256[] memory timestamps = new uint256[](5);
        timestamps[0] = block.timestamp;
        for (uint256 i = 1; i < timestamps.length; i++) {
            timestamps[i] = timestamps[i] + 1 days * _hem(_random(), 1, 365);
        }

        uint256 amount = 1 ether; // Fixed ETH amount for contributions

        for (uint256 i = 0; i < timestamps.length; i++) {
            console.log("\n=== Test Case", i + 1, "===");
            console.log("Timestamp:", timestamps[i]);

            vm.warp(timestamps[i]);

            // First do a contribution
            console.log("\n--- Contributing ETH ---");
            console.log("Amount:", amount);

            uint256 startLPNani = IERC20(NANI).balanceOf(address(LP));
            uint256 startLPWeth = IERC20(WETH).balanceOf(address(LP));
            uint256 startUserNani = IERC20(NANI).balanceOf(V);

            console.log("\nStarting Balances:");
            console.log("LP NANI Balance:", startLPNani);
            console.log("LP WETH Balance:", startLPWeth);
            console.log("User NANI Balance:", startUserNani);

            (, string memory startPriceStr) = ICTC(CTC).checkPriceInETH(NANI);
            (, string memory startPriceUSDCStr) = ICTC(CTC).checkPriceInETHToUSDC(NANI);

            console.log("\nStarting Prices:");
            console.log("ETH Price:", startPriceStr);
            console.log("USDC Price:", startPriceUSDCStr);

            vm.prank(V);
            nlp.contribute{value: amount}();

            uint256 midLPNani = IERC20(NANI).balanceOf(address(LP));
            uint256 midLPWeth = IERC20(WETH).balanceOf(address(LP));
            uint256 midUserNani = IERC20(NANI).balanceOf(V);

            bool isLPCreated = midLPNani > startLPNani && midLPWeth > startLPWeth;

            console.log("\nContribution Result:");
            if (isLPCreated) {
                console.log("Lottery Won - LP Position Created");
                console.log("NANI Added to LP:", midLPNani - startLPNani);
                console.log("WETH Added to LP:", midLPWeth - startLPWeth);
            } else {
                console.log("Direct Swap Performed");
                console.log("NANI Received:", midUserNani - startUserNani);
            }

            // Then do a sell if user has NANI
            if (midUserNani > 0) {
                console.log("\n--- Selling NANI ---");
                uint256 naniToSell = _hem(_random(), 1, midUserNani / 100);
                console.log("NANI Amount to Sell:", naniToSell);

                vm.startPrank(V);
                IERC20(NANI).approve(address(nans), naniToSell);
                nans.sell(V, naniToSell, 0);
                vm.stopPrank();

                uint256 endLPNani = IERC20(NANI).balanceOf(address(LP));
                uint256 endLPWeth = IERC20(WETH).balanceOf(address(LP));
                uint256 endUserNani = IERC20(NANI).balanceOf(V);

                (, string memory endPriceStr) = ICTC(CTC).checkPriceInETH(NANI);
                (, string memory endPriceUSDCStr) = ICTC(CTC).checkPriceInETHToUSDC(NANI);

                console.log("\nFinal Balances After Sell:");
                console.log("LP NANI Balance:", endLPNani);
                console.log("LP WETH Balance:", endLPWeth);
                console.log("User NANI Balance:", endUserNani);

                console.log("\nFinal Prices:");
                console.log("ETH Price:", endPriceStr);
                console.log("USDC Price:", endPriceUSDCStr);

                console.log("\nSell Impact:");
                // User sold NANI so their balance decreased
                console.log("NANI Sold:", naniToSell); // Use the actual amount we sold
                // LP gained NANI
                console.log("LP NANI Change:", endLPNani - midLPNani);
                // LP lost WETH
                console.log("LP WETH Change:", midLPWeth - endLPWeth);
            }

            // Reset state for next test
            vm.roll(block.number + 1);
        }
    }

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

    function _hem(uint256 x, uint256 min, uint256 max) internal pure returns (uint256 result) {
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
}

interface IERC20 {
    function balanceOf(address) external view returns (uint256);
    function transfer(address, uint256) external returns (bool);
    function approve(address, uint256) external returns (bool);
}

interface ICTC {
    function checkPriceInETH(address) external returns (uint256, string memory);
    function checkPriceInETHToUSDC(address) external returns (uint256, string memory);
}
