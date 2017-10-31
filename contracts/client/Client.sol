pragma solidity ^0.4.11;

import 'zeppelin-solidity/contracts/ownership/Ownable.sol';


contract Client is Ownable {

    mapping (bytes32 => bytes32) public data;

    mapping (address => uint256) internal rewardOffers;
    address[] public rewardOffersAddresses;

    //(offer => count). count - may be max == (MAX_COUNT_SHOWED_AD - 1).
    mapping(address => uint8) numbersViewedOffer;

    address[] internal searchRequests;

    function setSearchContract(address _searchContract) public;

    function setBaseContract(address _baseContract) public;

    function getData(bytes32[] keys) public constant returns (bytes32[]);

    function setData(bytes32[] keys, bytes32[] values) onlyOwner public;

    function getRewardByOffer(address advertAddress) public constant returns (uint256);

    function setRewardByOffer(address advertAddress, uint256 reward) public;

    function getNumberViewedOffer(address offerAddress) public constant returns(uint8);

    function incrementNumberViewedOffer(address offerAddress) public;

    function getSearchRequestAddresses() onlyOwner constant external returns (address[]);

    function setSearchRequestAddress(address searchRequest) public;

}
