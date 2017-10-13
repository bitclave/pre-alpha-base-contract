pragma solidity ^0.4.0;

import '../search/Search.sol';
import '../BaseContract.sol';


contract SearchContract is Search {
    using Bytes32Utils for bytes32;
    using SafeMath for uint256;

    BaseContract private baseContract;

    function SearchContract(){
        baseContract = BaseContract(msg.sender);
    }

    function getLatestSearchResult() external constant returns (address[]) {
        return latestSearchResult[msg.sender];
    }

    function search(address questionnaire, uint32[] questionnaireSteps) external {
        address clientAddress = baseContract.getClient(msg.sender);

        require(clientAddress != address(0));
        require(questionnaire != address(0x0));

        Client client = Client(clientAddress);

        delete latestSearchResult[msg.sender];
        latestSearchResult[msg.sender].length = 0;

        Offer[] storage offers = offerByQuestionnaires[questionnaire];
        for(uint i = 0; i < offers.length; i++) {
            if (offers[i].holderCoins().getBalance() >= offers[i].maxReward()
                    && mathByQuestionnaire(offers[i], questionnaire, questionnaireSteps)
                    && comparisonOfferRules(offers[i], client)) {
                latestSearchResult[msg.sender].push(offers[i]);
            }
        }
    }

    function mathByQuestionnaire(
        Offer offer,
        address questionnaire,
        uint32[] questionnaireSteps
    )
        private
        constant
        returns (bool)
    {
        Questionnaire questionnaireContract = Questionnaire(questionnaire);
        uint stepCount = questionnaireContract.getStepCount();
        require(questionnaireSteps.length == stepCount);

        if (offer.questionnaireStepsCount() != stepCount) {
            return false;
        }

        for(uint8 i = 0; i < stepCount; i++) {
            uint32 offerQuestionnaire = offer.questionnaireStep(i);

            if (questionnaireSteps[i] & offerQuestionnaire != questionnaireSteps[i]) {
                return false;
            }
        }

        return true;
    }

    function comparisonOfferRules(Offer offer, Client client) private returns (bool) {
        bytes32 clientKeyValue;
        bytes32 offerKeyValue;
        uint8 action;
        uint256 rewardPresents;

        for (uint i = 0; i < offer.getClientDataKeysCount(); i++) {
            clientKeyValue = client.data(offer.userDataKeys(i));
            offerKeyValue = offer.userDataValues(i);
            action = offer.matchActions(i);
            //0 - '=='; 1 - '!='; 2 - '<='; 3 - '>='; 4 - '>'; 5 - '<'.
            if ((action == 0 && clientKeyValue == offerKeyValue)
            || (action == 1 && clientKeyValue != offerKeyValue)
            || (action == 2 && clientKeyValue.toUInt() <= offerKeyValue.toUInt())
            || (action == 3 && clientKeyValue.toUInt() >= offerKeyValue.toUInt())
            || (action == 4 && clientKeyValue.toUInt() > offerKeyValue.toUInt())
            || (action == 5 && clientKeyValue.toUInt() < offerKeyValue.toUInt())) {
                rewardPresents += offer.mathRewardPercents(i);
            }
        }

        uint8 showedCount = mapAdvertShowedCount[msg.sender][address(offer)];

        if (rewardPresents >= MIN_PERCENTAGE_SIMILARITY) {
            if (showedCount <= MAX_COUNT_SHOWED_AD) {
                rewardPresents = rewardPresents.div(showedCount + 1);
                uint256 rewards = offer.maxReward().mul(rewardPresents).div(100);
                client.setRewardByOffer(address(offer), Math.max256(rewards, offer.minReward()));

            } else {
                client.setRewardByOffer(address(offer), 0);
            }

            return true;
        }

        client.setRewardByOffer(address(offer), 0);
        return false;
    }

    function addOffer(address questionnaire, address offer) public {
        require(questionnaire != address(0));
        require(offer != address(0));

        Questionnaire(questionnaire);
        Offer offerContract = Offer(offer);
        for (uint i = 0; i < offerByQuestionnaires[questionnaire].length; i++) {
            require(offerByQuestionnaires[questionnaire][i] != offer);
        }

        offerByQuestionnaires[questionnaire].push(offerContract);
    }

    function addClientDataKeys(bytes32[] keys) external {
        bool exist = false;
        for(uint i = 0; i < keys.length; i++) {
            exist = false;
            for (uint j = 0; j < clientDataKeys.length; j++) {
                if (clientDataKeys[j] == keys[i]) {
                    exist = true;
                    break;
                }
            }
            if (!exist) {
                clientDataKeys.push(keys[i]);
            }
        }
    }

    function getClientDataKeys() external constant returns(bytes32[]) {
        return clientDataKeys;
    }

}
