// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.19;

import {nlp} from "../src/nlp.sol";
import {Test} from "../lib/forge-std/src/Test.sol";
import {console} from "forge-std/console.sol";

contract nlpTest is Test {
    nlp internal n;

    address constant NANI = 0x00000000000007C8612bA63Df8DdEfD9E6077c97;
    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address constant DAO = 0xDa000000000000d2885F108500803dfBAaB2f2aA;
    address constant LP = 0x58Cf91C080F7052f6dA209BF605D6Cf1cefD65F3;

    address constant V = 0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045;
    address constant A = 0x0000000000001d8a2e7bf6bc369525A2654aa298;
    address constant CTC = 0x0000000000cDC1F8d393415455E382c30FBc0a84;

    function setUp() public payable {
        vm.createSelectFork(vm.rpcUrl("main"));
        n = new nlp();
        vm.prank(A);
        IERC20(NANI).transfer(address(n), 10_000_000 ether);
    }

    function testContribute() public payable {
        vm.prank(V);
        n.contribute{value: 0.015 ether}();
    }

    function testContributeAndCheckPrice() public payable {
        uint256 bal = IERC20(NANI).balanceOf(V);
        console.log(bal);
        (uint256 price, string memory strPrice) = ICTC(CTC).checkPriceInETH(NANI);
        console.log(price);
        console.log(strPrice);
        vm.prank(V);
        n.contribute{value: 0.015 ether}();
        (price, strPrice) = ICTC(CTC).checkPriceInETH(NANI);
        console.log(price);
        console.log(strPrice);
        bal = IERC20(NANI).balanceOf(V);
        console.log(bal);
    }
}

interface IERC20 {
    function balanceOf(address) external view returns (uint256);
    function transfer(address, uint256) external returns (bool);
    function approve(address, uint256) external returns (bool);
}

interface ICTC {
    function checkPriceInETH(address) external returns (uint256, string memory);
}
