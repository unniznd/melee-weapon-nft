// SPDX-License-Identifier: MIT

pragma solidity ^0.8.35;

import {Test, console} from "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";
import {DeployMeleeWeaponNFT} from "../../script/DeployMeleeWeaponNFT.s.sol";
import {MeleeWeapon} from "../../src/MeleeWeaponNFT.sol";
import {MintMeleeWeaponNFT, SwitchMeleeMeleeWeaponNFT} from "../../script/Interactions.s.sol";
import {ImageURI} from "../helpers/ImageURI.sol";

contract InteractionsTest is Test, ImageURI {
    DeployMeleeWeaponNFT public deployMeleeWeaponNFT;
    MeleeWeapon public meleeWeapon;

    address public USER = makeAddr("alice");

    function setUp() public {
        deployMeleeWeaponNFT = new DeployMeleeWeaponNFT();
        meleeWeapon = deployMeleeWeaponNFT.run();
    }

    modifier minted() {
        MintMeleeWeaponNFT mintMeleeWeaponNFT = new MintMeleeWeaponNFT();
        mintMeleeWeaponNFT.mintNFT(address(meleeWeapon));
        _;
    }

    /// @dev The interaction scripts broadcast without an explicit signer, so the resulting
    /// msg.sender is only known once the mint/switch actually lands on-chain. Rather than
    /// assuming a specific sender address, decode the emitted event and cross-check its
    /// `owner` field against the token's actual owner.
    function _assertMintedEventLogged(Vm.Log[] memory logs, uint256 expectedTokenId, MeleeWeapon.Melee expectedMelee)
        internal
    {
        bytes32 sig = keccak256("MeleeWeaponMinted(uint256,address,uint8)");
        for (uint256 i = 0; i < logs.length; i++) {
            if (logs[i].topics[0] == sig) {
                uint256 tokenId = uint256(logs[i].topics[1]);
                address owner = address(uint160(uint256(logs[i].topics[2])));
                MeleeWeapon.Melee melee = abi.decode(logs[i].data, (MeleeWeapon.Melee));

                assertEq(tokenId, expectedTokenId);
                assertEq(owner, meleeWeapon.ownerOf(expectedTokenId));
                assertEq(uint256(melee), uint256(expectedMelee));
                return;
            }
        }
        fail();
    }

    function _assertSwitchedEventLogged(Vm.Log[] memory logs, uint256 expectedTokenId, MeleeWeapon.Melee expectedMelee)
        internal
    {
        bytes32 sig = keccak256("MeleeWeaponSwitched(uint256,address,uint8)");
        for (uint256 i = 0; i < logs.length; i++) {
            if (logs[i].topics[0] == sig) {
                uint256 tokenId = uint256(logs[i].topics[1]);
                address owner = address(uint160(uint256(logs[i].topics[2])));
                MeleeWeapon.Melee melee = abi.decode(logs[i].data, (MeleeWeapon.Melee));

                assertEq(tokenId, expectedTokenId);
                assertEq(owner, meleeWeapon.ownerOf(expectedTokenId));
                assertEq(uint256(melee), uint256(expectedMelee));
                return;
            }
        }
        fail();
    }

    function test_MintNFTInteraction() public {
        MintMeleeWeaponNFT mintMeleeWeaponNFT = new MintMeleeWeaponNFT();

        vm.recordLogs();
        mintMeleeWeaponNFT.mintNFT(address(meleeWeapon));
        _assertMintedEventLogged(vm.getRecordedLogs(), 0, MeleeWeapon.Melee.KNIFE);

        assertEq(meleeWeapon.getTokenCounter(), 1);
        assertEq(meleeWeapon.tokenURI(0), KNIFE_URI);
        assertEq(meleeWeapon.getTokenIdToMelee(0), uint256(MeleeWeapon.Melee.KNIFE));
    }

    function test_RunMintsNft() public {
        vm.setEnv("MELEE_WEAPON_ADDRESS", vm.toString(address(meleeWeapon)));

        MintMeleeWeaponNFT mintScript = new MintMeleeWeaponNFT();

        vm.recordLogs();
        mintScript.run();
        _assertMintedEventLogged(vm.getRecordedLogs(), 0, MeleeWeapon.Melee.KNIFE);

        assertEq(meleeWeapon.getTokenCounter(), 1);
        assertEq(meleeWeapon.tokenURI(0), KNIFE_URI);
    }

    function test_SwitchMeleeInteraction() public minted {
        assertEq(meleeWeapon.getTokenCounter(), 1);
        assertEq(meleeWeapon.tokenURI(0), KNIFE_URI);
        assertEq(meleeWeapon.getTokenIdToMelee(0), uint256(MeleeWeapon.Melee.KNIFE));

        SwitchMeleeMeleeWeaponNFT switchMeleeMeleeWeaponNFT = new SwitchMeleeMeleeWeaponNFT();

        vm.recordLogs();
        switchMeleeMeleeWeaponNFT.switchMelee(address(meleeWeapon), 0);
        _assertSwitchedEventLogged(vm.getRecordedLogs(), 0, MeleeWeapon.Melee.BOXING_GLOVE);

        assertEq(meleeWeapon.getTokenCounter(), 1);
        assertEq(meleeWeapon.tokenURI(0), BOXING_GLOVE_URI);
        assertEq(meleeWeapon.getTokenIdToMelee(0), uint256(MeleeWeapon.Melee.BOXING_GLOVE));
    }

    function test_RunSwitchMeele() public {
        vm.setEnv("MELEE_WEAPON_ADDRESS", vm.toString(address(meleeWeapon)));

        MintMeleeWeaponNFT mintScript = new MintMeleeWeaponNFT();
        mintScript.run();

        SwitchMeleeMeleeWeaponNFT switchMeleeMeleeWeaponNFT = new SwitchMeleeMeleeWeaponNFT();

        vm.recordLogs();
        switchMeleeMeleeWeaponNFT.run(0);
        _assertSwitchedEventLogged(vm.getRecordedLogs(), 0, MeleeWeapon.Melee.BOXING_GLOVE);

        assertEq(meleeWeapon.getTokenCounter(), 1);
        assertEq(meleeWeapon.tokenURI(0), BOXING_GLOVE_URI);
    }
}
