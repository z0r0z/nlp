// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.19;

import {NLP} from "../src/NLP.sol";
import {NSFW} from "../src/NSFW.sol";
import {Test} from "../lib/forge-std/src/Test.sol";
import {console} from "forge-std/console.sol";

contract NLPTest is Test {
    NLP internal nlp;
    NSFW internal nsfw;

    address constant NANI = 0x00000000000007C8612bA63Df8DdEfD9E6077c97;
    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address constant DAO = 0xDa000000000000d2885F108500803dfBAaB2f2aA;
    address constant LP = 0x58Cf91C080F7052f6dA209BF605D6Cf1cefD65F3;

    address constant V = 0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045;
    address constant A = 0x0000000000001d8a2e7bf6bc369525A2654aa298;
    address constant CTC = 0x0000000000cDC1F8d393415455E382c30FBc0a84;

    address deployer;

    function setUp() public payable {
        uint256 deployerPrivateKey =
            0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
        deployer = vm.addr(deployerPrivateKey);

        vm.startPrank(deployer);
        vm.createSelectFork(vm.rpcUrl("main"));
        nlp = new NLP();
        nsfw = new NSFW();
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
