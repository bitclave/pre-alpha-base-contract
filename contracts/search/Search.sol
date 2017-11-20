pragma solidity ^0.4.11;

import '../offer/Offer.sol';
import '../Questionnaire.sol';
import '../helpers/SameOwner.sol';
import '../helpers/Bytes32Utils.sol';
import '../search/SearchRequest.sol';
import 'zeppelin-solidity/contracts/math/Math.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import 'zeppelin-solidity/contracts/lifecycle/Destructible.sol';
import 'zeppelin-solidity/contracts/lifecycle/Pausable.sol';

contract Search is SameOwner, Pausable, Destructible {

    event SearchFinished(address indexed searchRequestAddress);

    uint8 public constant MIN_PERCENTAGE_SIMILARITY = 50;
    uint8 public constant MAX_COUNT_SHOWED_AD = 3; //start from 0 (zero);

    //questionnaire =>
    mapping(address => Offer[]) public offersByQuestionnaires;

    bytes32[] internal clientDataKeys;

    function setBaseContract(address _baseContract) onlySameOwner public;

    function searchOffers(
        address searchRequestAddress,
        bytes32[] clientKeys,
        bytes32[] clientValues
    )
    whenNotPaused external;

    function addOffer(address offer) onlySameOwner public;

    function addClientDataKeys(bytes32[] keys) onlySameOwner public;

    function getClientDataKeys() external constant returns(bytes32[]);

    function addOffers(address[] offers) onlySameOwner public;

    function cloneContract(address newSearchContract) onlyOwner public;

}
