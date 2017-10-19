pragma solidity ^0.4.11;

import './PreCATToken.sol';
import './offer/HolderAdCoins.sol';
import './offer/Offer.sol';
import './offer/OfferContract.sol';
import './client/Client.sol';
import './client/ClientContract.sol';
import './Questionnaire.sol';
import './search/Search.sol';
import './search/SearchContract.sol';
import './helpers/Bytes32Utils.sol';
import 'zeppelin-solidity/contracts/math/Math.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';


contract BaseContract is Ownable {
    using Bytes32Utils for bytes32;
    using SafeMath for uint256;

    event ClientReward(address indexed _from, address indexed _to, uint256 _value);
    event CreateOffer(address indexed advertiser, address indexed advert);
    event CreateClient(address indexed client);

    address constant ADDRESS_CONTRACT_OF_TOKENS = 0xcF6137b80171540a9c6C10D3332E3de5d93B4EF7;

    mapping(address => Questionnaire) private questionnaireMap;
    address[] private questionnaires;

    //advertiser => array of offers
    mapping (address => address[]) private mapAdvertiserOffers;

    mapping (address => Client) private clients;

    PreCATToken public tokenContract = new PreCATToken('TOKEN', 'TKN'); //PreCATToken(ADDRESS_CONTRACT_OF_TOKENS);

    Search public searchContract;

    function BaseContract() {
    }

    function setTokensContract(address tokenContractAddress) onlyOwner external {
        tokenContract = PreCATToken(tokenContractAddress);
    }

	function setSearchContract(address searchContractAddress) onlyOwner external {
        searchContract = Search(searchContractAddress);
    }
	
    function getAdvertiserOffers() public constant returns(address[]) {
        return mapAdvertiserOffers[msg.sender];
    }

    function getQuestionnaires() external constant returns (address[]) {
        return questionnaires;
    }

    function transferClientRewards(address _offer) public {
        Client client = clients[msg.sender];
        Offer offer = Offer(_offer);

        require(client.getRewardByOffer(_offer) > 0);
        require(offer.holderCoins().getBalance() >= client.getRewardByOffer(_offer));

        uint256 reward = client.getRewardByOffer(_offer);
        client.setRewardByOffer(_offer, 0x0);

        offer.payReward(msg.sender, reward);

        uint8 showedCount = offer.getShowedCountByClient(msg.sender);
        if (showedCount < searchContract.MAX_COUNT_SHOWED_AD()) {
            offer.incrementShowedCount(msg.sender);
        }

        ClientReward(_offer, msg.sender,  reward);
    }

    function createOffer(address questionnaire) external {
        require(questionnaire > address(0x0));
        require(questionnaireMap[questionnaire].getStepCount() > 0);

        Offer offer = new OfferContract(
            msg.sender,
            questionnaire,
            address(tokenContract)
        );

        mapAdvertiserOffers[msg.sender].push(offer);

        searchContract.addOffer(questionnaire, address(offer));

        CreateOffer(
            msg.sender,
            address(offer)
        );
    }

    function createClient() external {
        require(clients[msg.sender] == address(0x0));

        clients[msg.sender] = new ClientContract(address(this), address(searchContract));
        clients[msg.sender].transferOwnership(msg.sender);
    }

    function getClient(address client) external constant returns (address) {
        return clients[client];
    }

    function addQuestionnaire(address questionnaire) onlyOwner external {
        for (uint i = 0; i < questionnaires.length; i++) {
            require(questionnaires[i] != questionnaire);
        }

        questionnaireMap[questionnaire] = Questionnaire(questionnaire);
        questionnaires.push(questionnaire);
    }

}
