// SPDX-License-Identifier: MIT
// Creator: Charlie Benson

pragma solidity 0.8.4;

import "./extensions/ERC721AQueryable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/**
 * @dev ERC721A variation w/ :
 * - Live ETH (Settable USD price) Mint Price Updates (Chainlink Feed),
 * - Transfer Pausable.
 * - Transfer+Mint Pausable.
 * - Whitelistable.
 * - URI Update.
 * - Token Creation Metadata.
 * - Set Max supply.
 * - Set USD NFT value (Purchased w/ ETH).
 * - Multi-Sig Compatible withdraw function. (Settable Treasury Address)
*/

contract EquityForSpectrum is ERC721A, ERC721AQueryable, Pausable, Ownable {
    uint public constant MAX_SUPPLY=3333;

    AggregatorV3Interface internal priceFeed;
    mapping(address => bool) public whitelist;
    address private _treasuryAddress;
    uint private _mintPriceUSD;
    string public baseTokenURI;
    
    constructor() ERC721A("Special", "SPCL") {
        //Set to default ETHUSD Chainlink Aggregator - GOERLI NETWORK
        priceFeed = AggregatorV3Interface(0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e);
        baseTokenURI = "ipfs://UPDATE_THIS_HASH";
        _treasuryAddress = owner();
        _mintPriceUSD = 333;        
    }


    function setBaseTokenURI(string memory _baseTokenURI) external onlyOwner {
        baseTokenURI = _baseTokenURI;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseTokenURI;
    }

    function _startTokenId() internal pure override returns (uint256) {
        return 1;
    }

    // Overrides the ERC721A function to just return the _baseURI (not incremented with tokenId)
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();

        string memory baseURI = _baseURI();
        return bytes(baseURI).length != 0 ? baseURI : '';
    }

    function mint(uint _mintAmount) external payable {
        uint mintPrice = getMintPriceWei();
        require(whitelist[msg.sender], "Not in Whitelist.");
        require(_mintAmount > 0, "Invalid Mint Amount Provided.");
        require(totalSupply() + _mintAmount <= MAX_SUPPLY, "Cannot mint more than Max Supply.");
        require(msg.value >= mintPrice * _mintAmount, "Value sent is less than cost of Minting.");
        _safeMint(msg.sender, _mintAmount);
    }
    

    function getMintPriceWei() public view returns (uint){
        uint eth = uint(getLatestETHUSDPrice());
        //USD / ETHUSD = WEI
        //10^26/10^8 = 10^18
        return (_mintPriceUSD * 10 ** 26)/ eth ;
    }

    function setMintPriceUSD(uint _newMintPrice) public onlyOwner{
        _mintPriceUSD = _newMintPrice;
    }

    function getLatestETHUSDPrice() public view returns(int){
        //returns USD *10**8
        (
            /*uint80 roundID*/,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();
        return price;
    }

    function getPriceFeedAddr() external view returns(address){
        return address(priceFeed);
    }

    function setPriceFeedAddr(address _priceFeed) external onlyOwner {
        priceFeed = AggregatorV3Interface(_priceFeed);
    }

    function addToWhitelist(address[] calldata addresses) external onlyOwner{
        for(uint i = 0; i < addresses.length; i++){
            whitelist[addresses[i]] = true;
        }
    }

    function removeFromWhitelist(address[] calldata addresses) external onlyOwner{
        for(uint i = 0; i < addresses.length; i++){
            delete whitelist[addresses[i]];
        }
    }

    function getTreasuryAddress() external view returns(address){
        return _treasuryAddress;
    }

    function setTreasuryAddress(address _newTreasuryAddress) external onlyOwner{
        _treasuryAddress = _newTreasuryAddress;
    }

    function withdraw() external onlyOwner{
        uint balance = address(this).balance;
        (bool success, ) = _treasuryAddress.call{value: balance}("");
        require(success, "Address reverted: Unable to send value to Treasury.");
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function makeTransferable() public onlyOwner {
        _makeTransferable();
    }

    function makeNotTransferable() public onlyOwner {
        _makeNotTransferable();
    }

    // overriding the hook to make pausable
    function _beforeTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal whenNotPaused override {}
}