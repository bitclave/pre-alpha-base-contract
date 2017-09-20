pragma solidity ^0.4.11;

import "./PreCATToken.sol";


contract HolderAdCoins {
    PreCATToken private tokenContract;
    address public owner;
    address public advertiser;
    uint public advertId;

    function HolderAdCoins(PreCATToken argTokenContract, address argAdvertiser, uint argAdvertId) {
        tokenContract = argTokenContract;
        owner = msg.sender;
        advertiser = argAdvertiser;
        advertId = argAdvertId;
    }

    function isOfferAddress(address addr) external constant returns (bool) {
        return addr == advertiser;
    }

    function transfer(address to, uint256 value) public returns (bool) {
        require(owner == msg.sender);
        tokenContract.transfer(to, value);
        //fix me. need return result from PreCatToken. but uploaded contract not have result of operations.
        // apply this when will be uploaded new contract with fix.
        return true;
    }

    function refund(uint256 value) public {
        require(advertiser == msg.sender);
        tokenContract.transfer(advertiser, value);
    }
}
