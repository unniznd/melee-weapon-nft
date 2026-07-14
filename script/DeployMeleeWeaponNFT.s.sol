// SPDX-License-Identifier: MIT

pragma solidity ^0.8.35;

import {Script} from "forge-std/Script.sol";
import {MeleeWeapon} from "../src/MeleeWeaponNFT.sol";
import {ImageURIHelper} from "../src/ImageURIHelper.sol";

contract DeployMeleeWeaponNFT is Script {
    function run() public returns (MeleeWeapon) {
        string memory pistolSvgImg = vm.readFile("imgs/pistol.svg");
        string memory knifeSvgImg = vm.readFile("imgs/knife.svg");
        string memory boxingGloveSvgImg = vm.readFile("imgs/boxing_glove.svg");

        vm.startBroadcast();
        MeleeWeapon meleeWeapon = new MeleeWeapon(
            ImageURIHelper.svgToImageURI(pistolSvgImg),
            ImageURIHelper.svgToImageURI(knifeSvgImg),
            ImageURIHelper.svgToImageURI(boxingGloveSvgImg)
        );
        vm.stopBroadcast();
        return meleeWeapon;
    }
}
