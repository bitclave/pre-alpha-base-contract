pragma solidity ^0.4.11;

import '../offer/Offer.sol';
import '../client/Client.sol';
import '../Questionnaire.sol';
import '../helpers/SameOwner.sol';
import '../helpers/Bytes32Utils.sol';
import '../search/SearchRequest.sol';
import 'zeppelin-solidity/contracts/math/Math.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import 'zeppelin-solidity/contracts/lifecycle/Destructible.sol';
import 'zeppelin-solidity/contracts/lifecycle/Pausable.sol';

contract Search is SameOwner, Pausable, Destructible {

    event SearchRequestCreated(
        address indexed clientOwnerAddress,
        address indexed searchRequestAddress
    );

    event SearchFinished(
        address indexed searchRequestAddress
    );

    uint8 public constant MIN_PERCENTAGE_SIMILARITY = 50;
    uint8 public constant MAX_COUNT_SHOWED_AD = 3; //start from 0 (zero);

    //questionnaire =>
    mapping(address => Offer[]) public offersByQuestionnaires;

    //questionnaire =>
    mapping(address => SearchRequest[]) public requestsByQuestionnaires;

    address[] internal searchRequests;

    bytes32[] internal clientDataKeys;

    function createSearch(address questionnaire, uint32[] questionnaireSteps) whenNotPaused public;

    function setBaseContract(address _baseContract) onlySameOwner public;

    function searchOffers(address searchRequestAddress) whenNotPaused external;

    function addOffer(address offer) onlySameOwner public;

    function addClientDataKeys(bytes32[] keys) onlySameOwner public;

    function getClientDataKeys() external constant returns(bytes32[]);

    function getSearchRequestsCount() onlySameOwner constant public returns (uint);

    function addOffers(address[] offers) onlySameOwner public;

    function addSearchRequests(address[] searchRequestAddresses) onlySameOwner public;

    function cloneContract(address newSearchContract) onlyOwner public;

}
