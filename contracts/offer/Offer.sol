pragma solidity ^0.4.11;

import "../offer/HolderAdCoins.sol";
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';


contract Offer is Ownable {

    event UpdateOffer(address indexed offeraddress);

    address public advertiser;
    address public questionnaireAddress;
    address public tokenContract;

    uint32[] internal questionnaireSteps;

    HolderAdCoins public holderCoins;
    string public url;
    string public shortDesc;
    string public imageUrl;

    uint256 public minReward;
    uint256 public maxReward;
    bytes32[] public userDataKeys;
    bytes32[] public userDataValues;
    uint8[] public matchActions; //0 - '=='; 1 - '!='; 2 - '<='; 3 - '>='; 4 - '>'; 5 - '<'.
    uint8[] public mathRewardPercents; // 0-100; percents for calculate rewards. (100 - this is max value of all items).

    function setOfferInfo(string _url, string _shortDesc, string _imageUrl) public;

    function setRules(
        uint256 _minReward,
        uint256 _maxReward,
        bytes32[] _userDataKeys,
        bytes32[] _userDataValues,
        uint8[] _matchActions,
        uint8[] _mathRewardPercents
    )
        public;

    function setQuestionnaireAddress(address _questionnaireAddress) public;

    function setTokensContract(address tokensContract) onlyOwner public;

    function getAdvertiser() constant returns (address);

    function getOffer() external constant returns (address, string, string, string);

    function getClientDataKeysCount() external constant returns (uint);

    function getRules() external constant returns (
        uint256,
        uint256,
        bytes32[],
        bytes32[],
        uint8[],
        uint8[]
    );

    function payReward(address to, uint256 value) onlyOwner public;

    function getQuestionnaireSteps() external constant returns (uint32[]);

    function questionnaireStepsCount() external constant returns (uint);

    function questionnaireStep(uint8 step) external constant returns (uint32);

    function setQuestionnaireSteps(uint32[] _questionnaireSteps) external;

}
