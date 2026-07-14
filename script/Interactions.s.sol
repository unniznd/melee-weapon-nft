// SPDX-License-Identifier: MIT

pragma solidity ^0.8.35;

import {Script, console} from "forge-std/Script.sol";
import {MeleeWeapon} from "../src/MeleeWeaponNFT.sol";
import {Vm, VmSafe} from "forge-std/Vm.sol";

contract MintMeleeWeaponNFT is Script {
    function run() external {
        address meleeWeapon = vm.envOr("MELEE_WEAPON_ADDRESS", address(0));
        if (meleeWeapon == address(0)) {
            Vm.BroadcastTxSummary memory broadcast =
                Vm(address(vm)).getBroadcast("MeleeWeapon", uint64(block.chainid), VmSafe.BroadcastTxType.Create);
            meleeWeapon = broadcast.contractAddress;
        }
        mintNFT(meleeWeapon);
    }

    function mintNFT(address meleeWeapon) public {
        vm.startBroadcast();
        MeleeWeapon(meleeWeapon).mintNft();
        vm.stopBroadcast();
    }
}

contract SwitchMeleeMeleeWeaponNFT is Script {
    function run(uint256 tokenId) external {
        address meleeWeapon = vm.envOr("MELEE_WEAPON_ADDRESS", address(0));
        if (meleeWeapon == address(0)) {
            Vm.BroadcastTxSummary memory broadcast =
                Vm(address(vm)).getBroadcast("MeleeWeapon", uint64(block.chainid), VmSafe.BroadcastTxType.Create);
            meleeWeapon = broadcast.contractAddress;
        }
        switchMelee(meleeWeapon, tokenId);
    }

    function switchMelee(address meleeWeapon, uint256 tokenId) public {
        vm.startBroadcast();
        MeleeWeapon(meleeWeapon).switchMelee(tokenId);
        vm.stopBroadcast();
    }
}
