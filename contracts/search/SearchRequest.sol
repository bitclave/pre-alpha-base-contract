pragma solidity ^0.4.0;

import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import '../Questionnaire.sol';


contract SearchRequest is Ownable {

    struct ClientReward {
        uint256 reward;
        uint8 numberOfViews;
    }

    mapping (address => ClientReward) rewards;

    address public questionnaire;
    uint32[] public answers; // request params
    mapping(address => bool) existedOffer;
    address[] public result; //addresses of offers
    address private mainOwner;

    function SearchRequest(
        address _questionnaire,
        uint32[] _answers,
        address _mainOwner
    )
    {
        require(_mainOwner != address(0x0));
        require(_questionnaire != address(0x0));

        Questionnaire questionnaireContract = Questionnaire(_questionnaire);
        uint stepCount = questionnaireContract.getStepCount();

        require(_answers.length == stepCount);
        require(questionnaireContract.isActive());

        questionnaire = _questionnaire;
        answers = _answers;
        mainOwner = _mainOwner;
    }

    function getResult() public constant returns (address[]) {
        return result;
    }

    function getResultLength() public constant returns(uint) {
        return result.length;
    }

    function addResultOffer(address offerAddress) public {
        require(Ownable(msg.sender).owner() == mainOwner);
        require(existedOffer[offerAddress] == false);
        result.push(offerAddress);
        existedOffer[offerAddress] = true;
    }

    function existOffer(address offerAddress) constant public returns(bool) {
        return existedOffer[offerAddress];
    }

    function getNumberOfViews(address offerAddress) constant public returns(uint8) {
        return rewards[offerAddress].numberOfViews;
    }

    function incrementNumberViewedOffer(address offerAddress) public {
        require(Ownable(msg.sender).owner() == mainOwner);
        rewards[offerAddress].numberOfViews++;
    }

    function getRewardByOffer(address offerAddress) constant public returns (uint256) {
        return rewards[offerAddress].reward;
    }

    function setRewardByOffer(address offerAddress, uint256 reward) public {
        require(Ownable(msg.sender).owner() == mainOwner);
        rewards[offerAddress].reward = reward;
    }
    
}
