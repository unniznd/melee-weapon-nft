// SPDX-License-Identifier: MIT

pragma solidity ^0.8.35;

import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

library ImageURIHelper {
    function svgToImageURI(string memory svg) internal pure returns (string memory) {
        string memory baseURI = "data:image/svg+xml;base64,";
        string memory svgBase64Encoded = Base64.encode(bytes(string(abi.encodePacked(svg))));
        return string(abi.encodePacked(baseURI, svgBase64Encoded));
    }
}
