// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

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

    string private baseURI;

    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;

    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;


    // ---------------------------------------------------------
    // EVENTS (Required by ERC721)
    // ---------------------------------------------------------

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);


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
        baseURI = _baseURI;

        owner = msg.sender;
        paused = false;
        totalSupply = 0;
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
    // VIEW FUNCTIONS
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

        emit Transfer(address(0), to, tokenId);
    }


    // ---------------------------------------------------------
    // TRANSFER LOGIC (STEP 5)
    // ---------------------------------------------------------

    function transferFrom(address from, address to, uint256 tokenId) public {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Not owner or approved");
        require(ownerOf(tokenId) == from, "Incorrect owner");
        require(to != address(0), "Cannot transfer to zero address");

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public {
        transferFrom(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "Receiver not ERC721 compliant");
    }


    function _transfer(address from, address to, uint256 tokenId) internal {
        _balances[from] -= 1;
        _balances[to] += 1;

        _owners[tokenId] = to;

        delete _tokenApprovals[tokenId];

        emit Transfer(from, to, tokenId);
    }


    // ---------------------------------------------------------
    // APPROVAL LOGIC (STEP 5)
    // ---------------------------------------------------------

    function approve(address to, uint256 tokenId) public {
        address ownerOfToken = ownerOf(tokenId);
        require(msg.sender == ownerOfToken || isApprovedForAll(ownerOfToken, msg.sender), 
                "Not authorized");

        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOfToken, to, tokenId);
    }

    function getApproved(uint256 tokenId) public view returns (address) {
        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public {
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address wallet, address operator) public view returns (bool) {
        return _operatorApprovals[wallet][operator];
    }


    // ---------------------------------------------------------
    // METADATA
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
        address ownerOfToken = ownerOf(tokenId);
        return (
            spender == ownerOfToken ||
            spender == _tokenApprovals[tokenId] ||
            isApprovedForAll(ownerOfToken, spender)
        );
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private returns (bool) {
        if (to.code.length == 0) return true; // not a contract

        (bool success, bytes memory result) = to.call(
            abi.encodeWithSignature(
                "onERC721Received(address,address,uint256,bytes)",
                msg.sender,
                from,
                tokenId,
                data
            )
        );

        return success && (result.length == 0 || abi.decode(result, (bytes4)) ==
            bytes4(keccak256("onERC721Received(address,address,uint256,bytes)")));
    }


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
