pragma solidity ^0.4.11;

import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import '../offer/Offer.sol';
import '../client/Client.sol';
import '../Questionnaire.sol';
import '../helpers/Bytes32Utils.sol';
import 'zeppelin-solidity/contracts/math/Math.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';


contract Search is Ownable {

    // client => (offer => count). count - may be max == (MAX_COUNT_SHOWED_AD - 1).
    mapping(address => mapping(address => uint8)) mapAdvertShowedCount;

    //questionnaire => Offers
    mapping(address => Offer[]) offerByQuestionnaires;

    //client => offers
    mapping (address => address[]) internal latestSearchResult;

    bytes32[] internal clientDataKeys;

    uint public constant MIN_PERCENTAGE_SIMILARITY = 50;
    uint8 public constant MAX_COUNT_SHOWED_AD = 3; //start from 0 (zero);

    function search(address questionnaire, uint32[] questionnaireSteps) external;

    function getLatestSearchResult() external constant returns (address[]);

    function addOffer(address questionnaire, address offer) public;

    function addClientDataKeys(bytes32[] keys) external;

    function getClientDataKeys() external constant returns(bytes32[]);

}
