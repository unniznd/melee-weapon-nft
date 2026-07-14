// SPDX-License-Identifier: MIT

pragma solidity ^0.8.35;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

/**
 * @title MeleeWeapon NFT: Simple melee weapon NFT
 * @author Aanand S (github.com/unniznd)
 * @notice This is simple on chain nft with different images of pistol, knife and boxing glove.
 * User can cycle between these NFTs
 * @dev Simple ERC721 contract that will mint on chain nft using svg in base64 and switch between them
 */

contract MeleeWeapon is ERC721 {
    /// @dev Error when unauthorized user try to switch nft image
    error MeleeWeapon__CantSwitchMelee();

    /// @notice Emitted when a new MeleeWeapon NFT is minted
    /// @param tokenId the id of the newly minted token
    /// @param owner the address the token was minted to
    /// @param melee the initial weapon skin assigned to the token
    event MeleeWeaponMinted(uint256 indexed tokenId, address indexed owner, Melee melee);

    /// @notice Emitted when a token's weapon skin is switched
    /// @param tokenId the id of the token that was switched
    /// @param owner the address that performed the switch
    /// @param melee the new weapon skin assigned to the token
    event MeleeWeaponSwitched(uint256 indexed tokenId, address indexed owner, Melee melee);

    /// @dev The enum of NFT svg images
    enum Melee {
        PISTOL,
        KNIFE,
        BOXING_GLOVE
    }

    /// @dev total melee count calculated
    uint256 private constant MELEE_COUNT = uint256(type(Melee).max) + 1;
    /// @notice total number of tokens minted
    uint256 private s_tokenCounter;
    /// @dev mapping from the token id to the melee enum
    mapping(uint256 => Melee) private s_tokenIdToMelee;
    /// @dev mapping from the melee enum to the base64 encoded svg image uri
    mapping(Melee => string) private s_meleeToImg;

    /// @notice Initalize the three base64 encoded svg image
    /// @param pistolSvgImgUri pistol svg image uri - base64 encoded
    /// @param knifeSvgImgUri knife svg image uri - base64 encoded
    /// @param boxingGloveSvgImgUri boxing glove svg image uri - base64 encoded
    constructor(string memory pistolSvgImgUri, string memory knifeSvgImgUri, string memory boxingGloveSvgImgUri)
        ERC721("MeleeWeapon", "MW")
    {
        /// @dev Assign token counter to zero
        s_tokenCounter = 0;
        /// @dev Save three base64 encoded image uri to mapping s_meleeToImg
        s_meleeToImg[Melee.KNIFE] = knifeSvgImgUri;
        s_meleeToImg[Melee.PISTOL] = pistolSvgImgUri;
        s_meleeToImg[Melee.BOXING_GLOVE] = boxingGloveSvgImgUri;
    }

    /// @notice Allow caller to mint the NFT
    function mintNft() public {
        /// @dev mint the nft to caller
        _safeMint(msg.sender, s_tokenCounter);
        /// @dev default NFT minted is KNIFE
        s_tokenIdToMelee[s_tokenCounter] = Melee.KNIFE;
        emit MeleeWeaponMinted(s_tokenCounter, msg.sender, Melee.KNIFE);
        /// @dev Increment the token counter
        s_tokenCounter++;
    }

    /// @notice Allow the nft owner to switch the nft between three (pistol, knife and boxing glove)
    /// @param tokenId token id to be switched
    function switchMelee(uint256 tokenId) public {
        /// @dev check if the owner is authorized to perform the action if not revert with error
        address owner = _requireOwned(tokenId);
        if (!_isAuthorized(owner, msg.sender, tokenId)) {
            revert MeleeWeapon__CantSwitchMelee();
        }
        /// @dev cycle the nft image between pistol, knife and boxing glove
        uint256 switchIndex = (uint256(s_tokenIdToMelee[tokenId]) + 1) % MELEE_COUNT;
        Melee newMelee = Melee(switchIndex);
        s_tokenIdToMelee[tokenId] = newMelee;
        emit MeleeWeaponSwitched(tokenId, msg.sender, newMelee);
    }

    /// @notice Prefix for encoded json
    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }

    /// @notice Get the token uri based on the id
    /// @param tokenId token id to fetch the token uri
    /// @return the encoded token uri string
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        /// @dev check if token id is valid
        _requireOwned(tokenId);

        /// @dev fetch the token details
        Melee melee = s_tokenIdToMelee[tokenId];
        string memory imageURI = s_meleeToImg[melee];

        /// @dev encode the data in the token uri format
        return string(
            abi.encodePacked(
                _baseURI(),
                Base64.encode(
                    bytes(
                        abi.encodePacked(
                            '{"name":"',
                            name(),
                            '", "description":"An NFT that reflects shows the melee weapon in hand", ',
                            '"attributes": [{"trait_type": "damage", "value": 100}], "image":"',
                            imageURI,
                            '"}'
                        )
                    )
                )
            )
        );
    }

    /* Getters */

    /// @notice Get the total number of tokens minted so far
    /// @return the current token counter, which is also the token id that will be minted next
    function getTokenCounter() external view returns (uint256) {
        return s_tokenCounter;
    }

    /// @notice Get the base64-encoded svg image uri for a given weapon skin
    /// @param melee the weapon skin to look up
    /// @return the base64-encoded svg image uri for the given skin
    function getMeleeImgUri(Melee melee) external view returns (string memory) {
        return s_meleeToImg[melee];
    }

    /// @notice Get the weapon skin currently assigned to a token
    /// @param tokenId the token id to look up
    /// @return the `Melee` enum value (as a uint256) currently assigned to the token
    function getTokenIdToMelee(uint256 tokenId) external view returns (uint256) {
        _requireOwned(tokenId);
        return uint256(s_tokenIdToMelee[tokenId]);
    }
}
