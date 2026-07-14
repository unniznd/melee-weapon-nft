// SPDX-License-Identifier: MIT

pragma solidity ^0.8.35;

import {Test, console} from "forge-std/Test.sol";
import {MeleeWeapon} from "../../src/MeleeWeaponNFT.sol";
import {ImageURIHelper} from "../../src/ImageURIHelper.sol";
import {IERC721Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";
import {ImageURI} from "../helpers/ImageURI.sol";

contract MeleeWeaponUnitTest is Test, ImageURI {
    string public constant NFT_NAME = "MeleeWeapon";
    string public constant NFT_SYMBOL = "MW";
    MeleeWeapon meleeWeapon;
    address public USER = makeAddr("user");
    string public pistolSvgImgUri;
    string public knifeSvgImgUri;
    string public boxingGloveSvgImgUri;

    function setUp() public {
        string memory pistolSvgImg = vm.readFile("imgs/pistol.svg");
        string memory knifeSvgImg = vm.readFile("imgs/knife.svg");
        string memory boxingGloveSvgImg = vm.readFile("imgs/boxing_glove.svg");

        pistolSvgImgUri = ImageURIHelper.svgToImageURI(pistolSvgImg);
        knifeSvgImgUri = ImageURIHelper.svgToImageURI(knifeSvgImg);
        boxingGloveSvgImgUri = ImageURIHelper.svgToImageURI(boxingGloveSvgImg);

        meleeWeapon = new MeleeWeapon(pistolSvgImgUri, knifeSvgImgUri, boxingGloveSvgImgUri);
    }

    function test_NameIsMeleeWeapon() public view {
        assertEq(meleeWeapon.name(), NFT_NAME);
    }

    function test_SymbolIsMW() public view {
        assertEq(meleeWeapon.symbol(), NFT_SYMBOL);
    }

    function test_ConstructorAssignmentSuccessful() public view {
        assertEq(meleeWeapon.getMeleeImgUri(MeleeWeapon.Melee.PISTOL), pistolSvgImgUri);
        assertEq(meleeWeapon.getMeleeImgUri(MeleeWeapon.Melee.KNIFE), knifeSvgImgUri);
        assertEq(meleeWeapon.getMeleeImgUri(MeleeWeapon.Melee.BOXING_GLOVE), boxingGloveSvgImgUri);
        assertEq(meleeWeapon.getTokenCounter(), 0);
    }

    modifier minted() {
        vm.prank(USER);
        meleeWeapon.mintNft();
        _;
    }

    function test_NFTMintSuccessful() public minted {
        string memory tokenUri = meleeWeapon.tokenURI(0);

        assertEq(meleeWeapon.getTokenCounter(), 1);
        assertEq(tokenUri, KNIFE_URI);
        assertEq(meleeWeapon.getTokenIdToMelee(0), uint256(MeleeWeapon.Melee.KNIFE));
    }

    function test_MintNftEmitsMeleeWeaponMinted() public {
        vm.expectEmit(true, true, false, true);
        emit MeleeWeapon.MeleeWeaponMinted(0, USER, MeleeWeapon.Melee.KNIFE);

        vm.prank(USER);
        meleeWeapon.mintNft();
    }

    function test_QueryTokenURIForNonExistentToken(uint256 tokenId) public {
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, tokenId));
        meleeWeapon.tokenURI(tokenId);
    }

    function test_OwnerOfGetNFTOwnerDetails() public minted {
        address owner = meleeWeapon.ownerOf(0);
        assertEq(owner, USER);
    }

    function test_OwnerOfInvalidToken(uint256 tokenId) public {
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, tokenId));
        meleeWeapon.ownerOf(tokenId);
    }

    function test_SwitchMeleeInvalidTokenId(uint256 tokenId) public {
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, tokenId));
        meleeWeapon.switchMelee(tokenId);
    }

    function test_SwitchMeleeWithDifferentOwner() public minted {
        address alice = makeAddr("alice");
        vm.prank(alice);
        vm.expectRevert(MeleeWeapon.MeleeWeapon__CantSwitchMelee.selector);
        meleeWeapon.switchMelee(0);
    }

    function test_SwitchMeleeWithCorrectOwner() public minted {
        string memory knifeTokenUri = meleeWeapon.tokenURI(0);
        console.log("knife ", meleeWeapon.getTokenIdToMelee(0));
        vm.startPrank(USER);
        meleeWeapon.switchMelee(0);

        string memory boxingTokenUri = meleeWeapon.tokenURI(0);
        console.log("boxing ", meleeWeapon.getTokenIdToMelee(0));

        meleeWeapon.switchMelee(0);
        vm.stopPrank();

        string memory pistolTokenUri = meleeWeapon.tokenURI(0);

        console.log("Pistol ", meleeWeapon.getTokenIdToMelee(0));

        assertEq(boxingTokenUri, BOXING_GLOVE_URI);
        assertEq(pistolTokenUri, PISTOL_URI);
        assertEq(knifeTokenUri, KNIFE_URI);
    }

    function test_SwitchMeleeEmitsMeleeWeaponSwitched() public minted {
        vm.expectEmit(true, true, false, true);
        emit MeleeWeapon.MeleeWeaponSwitched(0, USER, MeleeWeapon.Melee.BOXING_GLOVE);

        vm.prank(USER);
        meleeWeapon.switchMelee(0);
    }
}
