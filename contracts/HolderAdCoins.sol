pragma solidity ^0.4.11;

import "./PreCATToken.sol";


contract HolderAdCoins {
    address public owner;
    address public advertiser;
    uint public advertId;

    function HolderAdCoins(address argAdvertiser, uint argAdvertId) {
        owner = msg.sender;
        advertiser = argAdvertiser;
        advertId = argAdvertId;
    }

    function isOfferAddress(address addr) returns (bool) {
        return addr == advertiser;
    }

    function transfer(address preCatTokens, address to, uint256 value) {
        require(owner == msg.sender);

        PreCATToken tokenContract = PreCATToken(preCatTokens);
        tokenContract.transfer(to, value);
    }

    function refund(address preCatTokens, uint256 value) external {
        require(advertiser == msg.sender);

        PreCATToken tokenContract = PreCATToken(preCatTokens);
        tokenContract.transfer(advertiser, value);
    }
}
