pragma solidity ^0.4.0;

import '../search/Search.sol';
import '../base/Base.sol';


contract SearchContract is Search {
    using Bytes32Utils for bytes32;
    using SafeMath for uint256;

    Base public baseContract;

    function SearchContract(address _baseContract) {
        require(_baseContract != address(0x0));

        baseContract = Base(_baseContract);
    }

    function createSearch(
        address questionnaire,
        uint32[] questionnaireSteps
    )
        whenNotPaused
        public
    {
        address clientAddress = baseContract.getClient(msg.sender);

        require(questionnaire != address(0x0));
        require(clientAddress != address(0x0));

        SearchRequest request = new SearchRequest(
            questionnaire,
            questionnaireSteps,
            clientAddress
        );

        Client client = Client(clientAddress);
        client.setSearchRequestAddress(address(request));

        searchRequests.push(address(request));

        SearchRequestCreated(msg.sender, address(request));
    }

    function setBaseContract(address _baseContract) onlySameOwner public {
        require(Base(_baseContract).owner() == owner);

        baseContract = Base(_baseContract);
    }

    function searchOffers(address searchRequestAddress) whenNotPaused external {
        address clientAddress = baseContract.getClient(msg.sender);

        require(clientAddress != address(0x0));
        require(searchRequestAddress != address(0x0));

        Client client = Client(clientAddress);
        SearchRequest request = SearchRequest(searchRequestAddress);

        require (request.client() == clientAddress);

        address questionnaire = request.questionnaire();
        Offer[] storage offers = offersByQuestionnaires[questionnaire];
        Questionnaire questionnaireContract = Questionnaire(questionnaire);

        uint size = questionnaireContract.getStepCount();
        uint32[] memory answers = new uint32[](size);

        for(uint i = 0; i < size; i++) {
            answers[i] = request.answers(i);
        }

        for (i = 0; i < offers.length; i++) {
            if (offers[i].holderCoins().getBalance() >= offers[i].maxReward()
                && matchByQuestionnaire(offers[i], answers)
                && comparisonOfferRules(offers[i], client)
                && !request.existOffer(offers[i])) {

                request.addResultOffer(offers[i]);
            }
        }

        SearchFinished(searchRequestAddress);
    }

    function matchByQuestionnaire(
        Offer offer,
        uint32[] answers
    )
        private
        constant
        returns (bool)
    {
        if (offer.questionnaireStepsCount() != answers.length) {
            return false;
        }

        for (uint8 i = 0; i < answers.length; i++) {
            uint32 offerQuestionnaire = offer.questionnaireStep(i);

            if (answers[i] & offerQuestionnaire != answers[i]) {
                return false;
            }
        }

        return true;
    }

    function comparisonOfferRules(Offer offer, Client client) private returns (bool) {
        bytes32 clientKeyValue;
        bytes32 offerKeyValue;
        uint8 action;
        uint256 rewardPresents = offer.getClientDataKeysCount() == 0 ? 100 : 0;

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

        uint8 showedCount = client.getNumberViewedOffer(address(offer));

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

    function addOffer(address offer) onlySameOwner public {
        require(offer != address(0));
        Offer offerContract = Offer(offer);
        address questionnaire = offerContract.questionnaireAddress();

        require(questionnaire != address(0x0));

        uint size = offersByQuestionnaires[questionnaire].length;

        for (uint i = 0; i < size; i++) {
            require(offersByQuestionnaires[questionnaire][i] != offer);
        }

        offersByQuestionnaires[questionnaire].push(offerContract);
    }

    function addClientDataKeys(bytes32[] keys) onlySameOwner public {
        bool exist = false;
        for (uint i = 0; i < keys.length; i++) {
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

    function getClientDataKeys() external constant returns (bytes32[]) {
        return clientDataKeys;
    }

    function getSearchRequestsCount() onlySameOwner constant public returns (uint) {
        return searchRequests.length;
    }

    function addOffers(address[] offers) onlySameOwner public {
        for (uint i = 0; i < offers.length; i++) {
            Offer offer = Offer(offers[i]);
            offersByQuestionnaires[offer.questionnaireAddress()].push(offer);
        }
    }

    function addSearchRequests(address[] searchRequestAddresses) onlySameOwner public {
        searchRequests = searchRequestAddresses;

        for (uint i = 0; i < searchRequests.length; i++) {
            SearchRequest searchRequest = SearchRequest(searchRequests[i]);
            address questionnaire = searchRequest.questionnaire();
            requestsByQuestionnaires[questionnaire].push(searchRequest);
        }
    }

    function cloneContract(address newSearchContract) onlyOwner public {
        Search searchContract = Search(newSearchContract);

        searchContract.setBaseContract(baseContract);
        searchContract.addSearchRequests(searchRequests);

        for (uint i = 0; i < searchRequests.length; i++) {
            SearchRequest(searchRequests[i]).transferOwnership(searchContract);
        }

        address[] memory offers = new address[](baseContract.getOffersCount());

        for(i = 0; i < offers.length; i++) {
            offers[i] = baseContract.getOffer(i);
        }

        searchContract.addOffers(offers);

        searchContract.addClientDataKeys(clientDataKeys);
    }

}
