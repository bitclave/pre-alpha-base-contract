pragma solidity ^0.4.0;

import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import '../Questionnaire.sol';


contract SearchRequest is Ownable {

    address public questionnaire;
    uint32[] public answers; // request params
    address public client;
    mapping(address => bool) existedOffer;
    address[] public result; //addresses of offers
    address private baseContract;

    function SearchRequest(
        address _questionnaire,
        uint32[] _answers,
        address _client
    )
    {
        require(_questionnaire != address(0x0));

        Questionnaire questionnaireContract = Questionnaire(_questionnaire);
        uint stepCount = questionnaireContract.getStepCount();

        require(_answers.length == stepCount);
        require(questionnaireContract.isActive());

        questionnaire = _questionnaire;
        answers = _answers;
        client = _client;
    }

    function getResult() public constant returns (address[]) {
        return result;
    }

    function getResultLength() public constant returns(uint) {
        return result.length;
    }

    function addResultOffer(address offerAddress) onlyOwner public {
        require(existedOffer[offerAddress] == false);
        result.push(offerAddress);
        existedOffer[offerAddress] = true;
    }

    function existOffer(address offerAddress) constant public returns(bool) {
        return existedOffer[offerAddress];
    }

}
