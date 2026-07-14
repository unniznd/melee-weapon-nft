// SPDX-License-Identifier: MIT

pragma solidity ^0.8.35;

import {Test} from "forge-std/Test.sol";
import {DeployMeleeWeaponNFT} from "../../script/DeployMeleeWeaponNFT.s.sol";
import {MeleeWeapon} from "../../src/MeleeWeaponNFT.sol";
import {ImageURI} from "../helpers/ImageURI.sol";

contract MeleeWeaponIntegrationTest is Test, ImageURI {
    DeployMeleeWeaponNFT deployer;
    MeleeWeapon meleeWeapon;

    string public constant NFT_NAME = "MeleeWeapon";
    string public constant NFT_SYMBOL = "MW";

    address public alice = makeAddr("alice");
    address public bob = makeAddr("bob");
    address public eve = makeAddr("eve");

    function setUp() public {
        deployer = new DeployMeleeWeaponNFT();
        meleeWeapon = deployer.run();
    }

    function test_NFTNameAndSymbol() public view {
        assertEq(meleeWeapon.name(), NFT_NAME);
        assertEq(meleeWeapon.symbol(), NFT_SYMBOL);
    }

    function test_MultipleNFTMint() public {
        vm.expectEmit(true, true, false, true);
        emit MeleeWeapon.MeleeWeaponMinted(0, alice, MeleeWeapon.Melee.KNIFE);
        vm.prank(alice);
        meleeWeapon.mintNft();

        vm.expectEmit(true, true, false, true);
        emit MeleeWeapon.MeleeWeaponMinted(1, bob, MeleeWeapon.Melee.KNIFE);
        vm.prank(bob);
        meleeWeapon.mintNft();

        vm.expectEmit(true, true, false, true);
        emit MeleeWeapon.MeleeWeaponMinted(2, eve, MeleeWeapon.Melee.KNIFE);
        vm.prank(eve);
        meleeWeapon.mintNft();

        uint256 TOTAL_MINTED = 3;

        assertEq(meleeWeapon.getTokenCounter(), TOTAL_MINTED);
        assertEq(meleeWeapon.tokenURI(0), KNIFE_URI);
        assertEq(meleeWeapon.tokenURI(1), KNIFE_URI);
        assertEq(meleeWeapon.tokenURI(2), KNIFE_URI);
    }

    function test_MultipleNFTMintAndSwitchWeapon() public {
        vm.startPrank(alice);
        meleeWeapon.mintNft();
        vm.expectEmit(true, true, false, true);
        emit MeleeWeapon.MeleeWeaponSwitched(0, alice, MeleeWeapon.Melee.BOXING_GLOVE);
        meleeWeapon.switchMelee(0);
        vm.stopPrank();

        vm.startPrank(bob);
        meleeWeapon.mintNft();
        meleeWeapon.switchMelee(1);
        vm.expectEmit(true, true, false, true);
        emit MeleeWeapon.MeleeWeaponSwitched(1, bob, MeleeWeapon.Melee.PISTOL);
        meleeWeapon.switchMelee(1);
        vm.stopPrank();

        vm.startPrank(eve);
        meleeWeapon.mintNft();
        meleeWeapon.switchMelee(2);
        meleeWeapon.switchMelee(2);
        vm.expectEmit(true, true, false, true);
        emit MeleeWeapon.MeleeWeaponSwitched(2, eve, MeleeWeapon.Melee.KNIFE);
        meleeWeapon.switchMelee(2);
        vm.stopPrank();

        uint256 TOTAL_MINTED = 3;

        assertEq(meleeWeapon.getTokenCounter(), TOTAL_MINTED);
        assertEq(meleeWeapon.tokenURI(0), BOXING_GLOVE_URI);
        assertEq(meleeWeapon.tokenURI(1), PISTOL_URI);
        assertEq(meleeWeapon.tokenURI(2), KNIFE_URI);
    }
}
