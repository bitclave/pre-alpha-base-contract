pragma solidity ^0.4.0;

import 'zeppelin-solidity/contracts/lifecycle/Pausable.sol';
import 'zeppelin-solidity/contracts/lifecycle/Destructible.sol';
import 'zeppelin-solidity/contracts/token/BasicToken.sol';
import '../helpers/SameOwner.sol';
import '../search/Search.sol';


contract Base is SameOwner, Pausable, Destructible {

    event ClientReward(address indexed _from, address indexed _to, uint256 _value);
    event CreateOffer(address indexed advertiser, address offer);

    address[] internal questionnaires;

    //advertiser => array of offers
    mapping (address => address[]) internal mapAdvertiserOffers;
    address[] internal offers;

    BasicToken public tokenContract;

    Search public searchContract;

    function Base(){

    }

    function setTokensContract(address tokenContractAddress) onlySameOwner whenNotPaused external;

    function setSearchContract(address searchContractAddress) onlySameOwner whenNotPaused external;

    function getOffers() onlySameOwner constant external returns(address[]);

    function getOffer(uint index) onlySameOwner constant external returns(address);

    function getOffersCount() onlySameOwner constant external returns(uint);

    function getAdvertiserOffers() public constant returns(address[]);

    function getQuestionnaires() external constant returns (address[]);

    function transferClientRewards(address _offer, address searchRequest) whenNotPaused public;

    function createOffer(address questionnaire) onlySameOwner whenNotPaused public;

    function addQuestionnaire(address questionnaire) onlySameOwner whenNotPaused external;

    /**
        functional for clone information to other BaseContract
    */
    function cloneContract(address newBaseContract) onlyOwner public;

    function setQuestionnaires(address[] questionnaireContracts) onlySameOwner whenNotPaused public;

    function setOffers(address[] offersContracts) onlySameOwner whenNotPaused public;

}
