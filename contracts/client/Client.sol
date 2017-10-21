pragma solidity ^0.4.11;

import 'zeppelin-solidity/contracts/ownership/Ownable.sol';

contract Client is Ownable {

    mapping (bytes32 => bytes32) public data;
    mapping (address => uint256) internal rewardOffers;
    address[] public rewardOffersAddresses;

    function getData(bytes32[] keys) public constant returns (bytes32[]);

    function setData(bytes32[] keys, bytes32[] values) onlyOwner public;

    function getRewardByOffer(address advertAddress) public constant returns (uint256);

    function setRewardByOffer(address advertAddress, uint256 reward) public;

}
