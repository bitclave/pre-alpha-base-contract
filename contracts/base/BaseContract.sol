pragma solidity ^0.4.11;

import '../base/Base.sol';
import '../offer/HolderAdCoins.sol';
import '../offer/Offer.sol';
import '../Questionnaire.sol';
import '../helpers/Bytes32Utils.sol';
import 'zeppelin-solidity/contracts/math/Math.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';


contract BaseContract is Base {
    using Bytes32Utils for bytes32;
    using SafeMath for uint256;

    function BaseContract() {
    }

    function setTokensContract(address tokenContractAddress) onlySameOwner whenNotPaused external {
        tokenContract = BasicToken(tokenContractAddress);

        for (uint i = 0; i < offers.length; i++){
            Offer offer = Offer(offers[i]);
            if (address(offer.tokenContract) != address(tokenContractAddress)) {
                offer.setTokensContract(tokenContract);
            }
        }
    }

    function getOffers() onlySameOwner constant external returns(address[]) {
        return offers;
    }

    function getOffer(uint index) onlySameOwner constant external returns(address) {
        require(index < offers.length && index >= 0);

        return offers[index];
    }

    function getOffersCount() onlySameOwner constant external returns(uint) {
        return offers.length;
    }

    function getAdvertiserOffers() public constant returns(address[]) {
        return mapAdvertiserOffers[msg.sender];
    }

    function getQuestionnaires() external constant returns (address[]) {
        return questionnaires;
    }

    function transferClientRewards(address client, address _offer, uint256 reward) onlyOwner whenNotPaused public {
        require(_offer != address(0x0));
        require(client != address(0x0));

        Offer offer = Offer(_offer);

        require(offer.holderCoins().getBalance() >= reward);

        offer.payReward(client, reward);

        ClientReward(_offer, client,  reward);
    }

    function addOffer(address offer) whenNotPaused public {
        require(Offer(offer).owner() == address(this));
        require(Offer(offer).tokenContract() == address(tokenContract));

        Questionnaire questionnaire = Questionnaire(Offer(offer).questionnaireAddress());
        require(Questionnaire(questionnaire).getStepCount() > 0);

        for(uint i = 0; i < mapAdvertiserOffers[msg.sender].length; i++) {
            require(mapAdvertiserOffers[msg.sender][i] != offer);
        }

        for(i = 0; i < offers.length; i++) {
            require(offers[i] != address(offer));
        }

        mapAdvertiserOffers[msg.sender].push(address(offer));
        offers.push(address(offer));

        AddOffer(msg.sender, address(offer));
    }

    function updateOfferEvent(address offer) whenNotPaused public {
        require(msg.sender == offer);
        UpdateOffer(offer);
    }

    function addQuestionnaire(address questionnaire) onlySameOwner whenNotPaused external {
        require(questionnaire != address(0x0));

        for (uint i = 0; i < questionnaires.length; i++) {
            require(questionnaires[i] != questionnaire);
        }

        questionnaires.push(questionnaire);
    }

    function cloneContract(address newBaseContract) onlyOwner public {
        require(newBaseContract != address(0x0));
        require(Base(newBaseContract).owner() == owner);

        Base baseContract = Base(newBaseContract);
        baseContract.setQuestionnaires(questionnaires);

        for(uint i = 0; i < offers.length; i++) {
            Offer offer = Offer(offers[i]);
            offer.transferOwnership(address(baseContract));
        }

        baseContract.setOffers(offers);

        baseContract.setTokensContract(address(tokenContract));
    }

    function setQuestionnaires(address[] questionnaireContracts) onlySameOwner whenNotPaused public {
        questionnaires = questionnaireContracts;
    }

    function setOffers(address[] offersContracts) onlySameOwner whenNotPaused public {
        offers = offersContracts;

        for(uint i = 0; i < offers.length; i++) {
            Offer offer = Offer(offers[i]);
            mapAdvertiserOffers[offer.getAdvertiser()].push(address(offer));
        }
    }

}
