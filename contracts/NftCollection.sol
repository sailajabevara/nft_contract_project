// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/*
 * STEP 4 — METADATA + BASE URI + TOKEN URI HANDLING
 *
 * New features added in this step:
 *  - baseURI storage
 *  - setBaseURI (owner only)
 *  - full tokenURI implementation (baseURI + tokenId)
 *  - _toString() helper for uint256 → string
 */

contract NftCollection {

    // ---------------------------------------------------------
    // STATE VARIABLES
    // ---------------------------------------------------------

    string public name;
    string public symbol;

    uint256 public maxSupply;
    uint256 public totalSupply;

    address public owner;
    bool public paused;

    string private baseURI; // NEW in Step 4

    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;

    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;


    // ---------------------------------------------------------
    // MODIFIERS
    // ---------------------------------------------------------

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    modifier whenNotPaused() {
        require(!paused, "Minting paused");
        _;
    }


    // ---------------------------------------------------------
    // CONSTRUCTOR
    // ---------------------------------------------------------

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _maxSupply,
        string memory _baseURI
    ) {
        name = _name;
        symbol = _symbol;
        maxSupply = _maxSupply;
        totalSupply = 0;

        owner = msg.sender;
        paused = false;

        baseURI = _baseURI; // NEW
    }


    // ---------------------------------------------------------
    // ADMIN FUNCTIONS
    // ---------------------------------------------------------

    function pause() external onlyOwner {
        paused = true;
    }

    function unpause() external onlyOwner {
        paused = false;
    }

    function setBaseURI(string calldata newBaseURI) external onlyOwner {
        baseURI = newBaseURI;
    }


    // ---------------------------------------------------------
    // ERC-721 REQUIRED FUNCTION IMPLEMENTATIONS
    // ---------------------------------------------------------

    function balanceOf(address wallet) public view returns (uint256) {
        require(wallet != address(0), "Zero address invalid");
        return _balances[wallet];
    }

    function ownerOf(uint256 tokenId) public view returns (address) {
        address currentOwner = _owners[tokenId];
        require(currentOwner != address(0), "Token does not exist");
        return currentOwner;
    }


    // ---------------------------------------------------------
    // MINTING
    // ---------------------------------------------------------

    function safeMint(address to, uint256 tokenId)
        public
        onlyOwner
        whenNotPaused
    {
        require(to != address(0), "Cannot mint to zero address");
        require(!_exists(tokenId), "Token already exists");
        require(totalSupply < maxSupply, "Max supply reached");

        _mint(to, tokenId);
    }

    function _mint(address to, uint256 tokenId) internal {
        _owners[tokenId] = to;
        _balances[to] += 1;
        totalSupply += 1;
    }


    // ---------------------------------------------------------
    // APPROVALS, TRANSFERS (PLACEHOLDERS)
    // ---------------------------------------------------------

    function transferFrom(address from, address to, uint256 tokenId) public {
        // Full logic will be implemented in Step 5
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public {
        // Full logic will be implemented in Step 5
    }

    function approve(address to, uint256 tokenId) public {
        // Implemented in Step 5
    }

    function setApprovalForAll(address operator, bool approved) public {
        _operatorApprovals[msg.sender][operator] = approved;
    }

    function getApproved(uint256 tokenId) public view returns (address) {
        return _tokenApprovals[tokenId];
    }

    function isApprovedForAll(address wallet, address operator) public view returns (bool) {
        return _operatorApprovals[wallet][operator];
    }


    // ---------------------------------------------------------
    // METADATA — FULL tokenURI IMPLEMENTATION (STEP 4)
    // ---------------------------------------------------------

    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId), "Query for non-existent token");

        return string(abi.encodePacked(baseURI, _toString(tokenId)));
    }


    // ---------------------------------------------------------
    // INTERNAL HELPERS
    // ---------------------------------------------------------

    function _exists(uint256 tokenId) internal view returns (bool) {
        return _owners[tokenId] != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId)
        internal
        view
        returns (bool)
    {
        // Will be fully implemented in Step 5
        return false;
    }

    // uint256 → string converter
    function _toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) return "0";

        uint256 temp = value;
        uint256 digits;

        while (temp != 0) {
            digits++;
            temp /= 10;
        }

        bytes memory buffer = new bytes(digits);

        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + value % 10));
            value /= 10;
        }

        return string(buffer);
    }
}
