pragma solidity ^0.4.11;

import 'zeppelin-solidity/contracts/token/BasicToken.sol';
import "../offer/Offer.sol";
import '../Questionnaire.sol';

contract OfferContract is Offer {

    function OfferContract(
        address _advertiser,
        address _questionnaireAddress,
        address _tokenContract
    )
    {
        require(_advertiser != address(0x0));
        require(_questionnaireAddress != address(0x0));
        require(_tokenContract != address(0x0));
        require(Questionnaire(_questionnaireAddress).getStepCount() > 0);

        advertiser = _advertiser;

        setQuestionnaireAddress(_questionnaireAddress);
        holderCoins = new HolderAdCoins(_tokenContract, _advertiser);
    }

    function isActive() public constant returns (bool){
        return BasicToken(tokenContract).balanceOf(address(this)) >= maxReward;
    }

    function setOfferInfo(string _url, string _shortDesc, string _imageUrl) public {
        require(msg.sender == advertiser);

        url = _url;
        shortDesc = _shortDesc;
        imageUrl = _imageUrl;
    }

    function setRules(
        uint256 _minReward,
        uint256 _maxReward,
        bytes32[] _userDataKeys,
        bytes32[] _userDataValues,
        uint8[] _matchActions,
        uint8[] _mathRewardPercents
    )
        public
    {
        require(msg.sender == advertiser);
        require(_minReward > 0);
        require(_maxReward > _minReward);
        require(_matchActions.length == _mathRewardPercents.length);
        require(_userDataKeys.length == _userDataValues.length);

        minReward = _minReward;
        maxReward = _maxReward;
        userDataKeys = _userDataKeys;
        userDataValues = _userDataValues;
        matchActions = _matchActions;
        mathRewardPercents = _mathRewardPercents;
    }

    function setQuestionnaireAddress(address _questionnaireAddress) public {
        require(msg.sender == advertiser || msg.sender == owner);

        questionnaireAddress = _questionnaireAddress;
    }

    function setTokensContract(address _tokensContract) onlyOwner external {
        holderCoins.setTokensContract(_tokensContract);
        tokenContract = _tokensContract;
    }

    function getOffer() external constant returns (address, string, string, string) {
        return (holderCoins, url, shortDesc, imageUrl);
    }

    function getClientDataKeysCount() external constant returns (uint) {
        return userDataKeys.length;
    }

    function getRules() external constant returns (
        uint256,
        uint256,
        bytes32[],
        bytes32[],
        uint8[],
        uint8[]
    )
    {
        return (
            minReward,
            maxReward,
            userDataKeys,
            userDataValues,
            matchActions,
            mathRewardPercents
        );
    }

    function getShowedCountByClient(address client) public constant returns (uint8) {
        return showedCount[client];
    }

    function incrementShowedCount(address client) public {
        showedCount[client]++;
    }

    function payReward(address to, uint256 reward) onlyOwner public {
        holderCoins.transfer(to, reward);
    }

    function getQuestionnaireSteps() external constant returns (uint32[]) {
        return questionnaireSteps;
    }

    function questionnaireStepsCount() external constant returns (uint) {
        return questionnaireSteps.length;
    }

    function questionnaireStep(uint8 step) external constant returns (uint32){
        require(step < questionnaireSteps.length);

        return questionnaireSteps[step];
    }

    function setQuestionnaireSteps(uint32[] _questionnaireSteps) external {
        questionnaireSteps = _questionnaireSteps;
    }

}
