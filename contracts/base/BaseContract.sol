pragma solidity ^0.4.11;

import '../base/Base.sol';
import '../offer/HolderAdCoins.sol';
import '../offer/Offer.sol';
import '../offer/OfferContract.sol';
import '../client/ClientContract.sol';
import '../Questionnaire.sol';
import '../search/Search.sol';
import '../search/SearchContract.sol';
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
        require(Ownable(tokenContractAddress).owner() == owner);

        tokenContract = BasicToken(tokenContractAddress);

        for(uint i = 0; i < offers.length; i++ ){
            Offer offer = Offer(offers[i]);
            if (address(offer.tokenContract) != address(tokenContractAddress)) {
                offer.setTokensContract(tokenContract);
            }
        }
    }

	function setSearchContract(address searchContractAddress) onlySameOwner whenNotPaused external {
        require(Search(searchContractAddress).owner() == owner);

        searchContract = Search(searchContractAddress);

        for (uint i = 0; i< clientList.length; i++) {
            Client client = Client(clientList[i]);
            client.setSearchContract(address(searchContractAddress));
        }
    }

    function getClients() onlySameOwner constant external returns(address[]) {
        return clientList;
    }

    function getOffers() onlySameOwner constant external returns(address[]) {
        return offers;
    }

    function getAdvertiserOffers() public constant returns(address[]) {
        return mapAdvertiserOffers[msg.sender];
    }

    function getQuestionnaires() external constant returns (address[]) {
        return questionnaires;
    }

    function transferClientRewards(address _offer) whenNotPaused public {
        Client client = clients[msg.sender];
        Offer offer = Offer(_offer);

        require(client.getRewardByOffer(_offer) > 0);
        require(offer.holderCoins().getBalance() >= client.getRewardByOffer(_offer));

        uint256 reward = client.getRewardByOffer(_offer);
        client.setRewardByOffer(_offer, 0x0);

        uint8 showedCount = offer.getShowedCountByClient(msg.sender);
        if (showedCount < searchContract.MAX_COUNT_SHOWED_AD()) {
            offer.incrementShowedCount(msg.sender);
        }

        offer.payReward(msg.sender, reward);

        ClientReward(_offer, msg.sender,  reward);
    }

    function createOffer(address questionnaire) whenNotPaused public {
        require(questionnaire != address(0x0));
        require(Questionnaire(questionnaire).getStepCount() > 0);

        Offer offer = new OfferContract(
            msg.sender,
            questionnaire,
            address(tokenContract)
        );

        mapAdvertiserOffers[msg.sender].push(address(offer));

        offers.push(address(offer));

        searchContract.addOffer(questionnaire, address(offer));

        CreateOffer(msg.sender, address(offer));
    }

    function createClient() whenNotPaused external {
        require(clients[msg.sender] == address(0x0));

        clients[msg.sender] = new ClientContract(address(this), address(searchContract));
        clients[msg.sender].transferOwnership(msg.sender);

        clientList.push(address(clients[msg.sender]));

        CreateClient(msg.sender, address(clients[msg.sender]));
    }

    function getClient(address ownerOfClientContract) external constant returns (address) {
        return clients[ownerOfClientContract];
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

        for(uint i = 0; i < clientList.length; i++) {
            Client client = Client(clientList[i]);
            client.setBaseContract(address(baseContract));
        }

        baseContract.setClients(clientList);

        for(i = 0; i < offers.length; i++) {
            Offer offer = Offer(offers[i]);
            offer.transferOwnership(address(baseContract));
        }

        baseContract.setOffers(offers);

        searchContract.setBaseContract(address(baseContract));

        baseContract.setTokensContract(address(tokenContract));
        baseContract.setSearchContract(address(searchContract));
    }

    function setQuestionnaires(address[] questionnaireContracts) onlySameOwner whenNotPaused public {
        questionnaires = questionnaireContracts;
    }

    function setClients(address[] clientContracts) onlySameOwner whenNotPaused public {
        clientList = clientContracts;
        for(uint i = 0; i < clientList.length; i++) {
            Client client = Client(clientList[i]);
            clients[client.owner()] = client;
        }
    }

    function setOffers(address[] offersContracts) onlySameOwner whenNotPaused public {
        offers = offersContracts;

        for(uint i = 0; i < offers.length; i++) {
            Offer offer = Offer(offers[i]);
            mapAdvertiserOffers[offer.getAdvertiser()].push(address(offer));
        }
    }

}