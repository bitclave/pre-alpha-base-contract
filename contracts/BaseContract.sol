pragma solidity ^0.4.11;


contract BaseContract {
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    struct Client {
        // need remove this. but, how!?
        mapping (uint => bool) searchAdvertIds;
        uint[] resultIds;
        mapping(bytes32 => bytes32) info;
        mapping(uint => uint256) rewards;
    }

    struct ClientInfoKeys {
        mapping (bytes32 => bool) existed;
        bytes32[] keys;
    }

    struct Rules {
        uint256 minWorth;
        uint256 maxWorth;
        bytes32[] key;
        bytes32[] value;
        uint8[] action; //0 - '=='; 1 - '!='; 2 - '<='; 3 - '>='; 4 - '>'; 5 - '<'.
        uint8[] worth; // 0-100; worth for calculate rewards. (100 - this is max value of all items).
    }

    struct Advert {
        uint advertId;
        address offerAddress;
        uint256 rewardsCoins;
        mapping (bytes32 => bytes32) searchData;
        string url;
        string shortDesc;
        string imageUrl;
        Rules rules;
    }

    struct SubCategories {
        mapping (bytes32 => uint[]) mapCategories; // name of categories => advertIds;
        bytes32[] categories;
        bool exists;
    }

    // advertTypes (car/home etc) => struct(second categories (mark, city etc.) => array of id);
    mapping (bytes32 => SubCategories) rootSearch;

    // car/home/tv/phones/animals etc.
    bytes32[] private advertTypes;

    // index of items adverts for generate unique number
    uint private advertsCount;
    mapping (uint => Advert) private adverts;

    mapping (address => Client) private clients;

    ClientInfoKeys clientInfoKeys;

    function BaseContract() {
    }

    function getClientInfoFields() public returns(bytes32[]) {
        return clientInfoKeys.keys;
    }

    function getSubCategories(bytes32 advertType) public returns (bytes32[]) {
        return rootSearch[advertType].categories;
    }

    function getAdvertTypes() public returns (bytes32[]) {
        return advertTypes;
    }

    function getAdvert(uint advertId) public returns (string url, string shortDesc, string imageUrl) {
        Advert storage advert = adverts[advertId];
        return (advert.url, advert.shortDesc, advert.imageUrl);
    }

    function saveUserInfo(bytes32[] keys, bytes32[] values) public {
        mapping(bytes32 => bytes32) info = clients[msg.sender].info;
        for (uint i = 0; i < keys.length; i++)
            info[keys[i]] = values[i];
    }

    function transferUserRewards(uint advertId) public payable returns (uint256) {
        address addr = msg.sender;
        require(addr != 0x0);
        require(clients[addr].rewards[advertId] > 0);
        require(adverts[advertId].rewardsCoins >= clients[addr].rewards[advertId]);

        uint256 reward = clients[addr].rewards[advertId];
        adverts[advertId].rewardsCoins -= clients[addr].rewards[advertId];
        clients[addr].rewards[advertId] = 0;

        //todo Transfer inside coint like a CAT!?
        Transfer(adverts[advertId].offerAddress, addr, reward);

        return reward;
    }

    // todo separate to few functions.
    //todo need to remove coins from the address in advance. (CAT!?)
    function createAdvertInCatalog(
        uint256 rewardsCoins,
        bytes32 argAdvertType,
        bytes32[] argCategories,
        bytes32[] argCategoryValues,
        string argUrl,
        string argShortDesc,
        string argImageUrl,
        uint256 rulesMinWorth,
        uint256 rulesMaxWorth,
        bytes32[] rulesKey,
        bytes32[] rulesValue,
        uint8[] rulesAction,
        uint8[] rulesWorth
    )
        public
        returns (uint256)
    {
        require(msg.sender > 0x0);
        require(argCategories.length == argCategoryValues.length);

        advertsCount++;

        updateSubCategories(argAdvertType, argCategories);
        createOfferWordsByAdvertType(argAdvertType);

        adverts[advertsCount] = Advert(
            advertsCount,
            msg.sender,
            rewardsCoins,
            argUrl,
            argShortDesc,
            argImageUrl,
            Rules(rulesMinWorth, rulesMaxWorth, rulesKey, rulesValue, rulesAction, rulesWorth)
        );

        updateAdvertSearchData(adverts[advertsCount], argCategories, argCategoryValues);
        mergeClientInfoKeys(rulesKey);

        return advertsCount;
    }

    function searchAdvert(
        bytes32 advertType,
        bytes32[] categories,
        bytes32[] categoryValues
    )
        public
        returns (uint256[])
    {
        address addr = msg.sender;
        mapping (uint256 => bool) advertIds = clients[addr].searchAdvertIds;
        uint256[] storage resultIds = clients[addr].resultIds;

        SubCategories storage subCategories = rootSearch[advertType];

        if (subCategories.exists == false)
            return new uint256[](0);

        for(uint i = 0; i < categories.length; i++) {
            uint256[] memory ids = subCategories.mapCategories[categories[i]];

            for (uint j = 0; j < ids.length; j++) {
               if(!advertIds[ids[j]]) {
                   advertIds[ids[j]] = true;
                  if (comparisonAdvertData(adverts[ids[j]], categories, categoryValues)
                        && comparisonAdvertRules(addr, adverts[ids[j]])) {
                      resultIds.push(ids[j]);
                  }
               }
            }
        }

        return resultIds;
    }


    function updateAdvertSearchData(
        Advert storage advert,
        bytes32[] argCategories,
        bytes32[] argCategoryValues
    )
        private
    {
        for(uint i = 0; i < argCategories.length; i++)
            advert.searchData[argCategories[i]] = argCategoryValues[i];
    }

    function updateSubCategories(
        bytes32 argAdvertType,
        bytes32[] argCategories
    )
        private
    {
        SubCategories storage subCategories = rootSearch[argAdvertType];

        for (uint i = 0; i < argCategories.length; i++) {
            if (subCategories.mapCategories[argCategories[i]].length == 0)
                subCategories.categories.push(argCategories[i]);

            subCategories.mapCategories[argCategories[i]].push(advertsCount);
        }
    }

    function mergeClientInfoKeys(bytes32[] keys) private {
        for(uint i = 0; i < keys.length; i++) {
            if (!clientInfoKeys.existed[keys[i]]) {
                clientInfoKeys.keys.push(keys[i]);
                clientInfoKeys.existed[keys[i]] = true;
            }
        }
    }

    function comparisonAdvertData(
        Advert storage advert,
        bytes32[] categories,
        bytes32[] categoryValues
    )
        private
        returns (bool)
    {
        if (advert.rewardsCoins < advert.rules.maxWorth) {
            return false;
        }

        for(uint i = 0; i < categories.length; i++) {
           if (advert.searchData[categories[i]] != categoryValues[i])
                return false;
        }

        return true;
    }

    function comparisonAdvertRules(address addr, Advert advert) private returns (bool) {
        Client storage client = clients[addr];
        mapping (bytes32 => bytes32) info = client.info;
        bytes32 clientKeyValue;
        bytes32 advertKeyValue;
        uint8 action;
        uint worth;
        uint worthPresents;

        for (uint i = 0; i < advert.rules.key.length; i++) {
            clientKeyValue = info[advert.rules.key[i]];
            advertKeyValue = advert.rules.value[i];
            action = advert.rules.action[i];
            worth = 0;
            if (action == 0 && clientKeyValue == advertKeyValue)
                worth = advert.rules.worth[i];

            else if (action == 1 && clientKeyValue != advertKeyValue)
                worth = advert.rules.worth[i];

            else if (action == 2 && clientKeyValue <= advertKeyValue)
                worth = advert.rules.worth[i];

            else if (action == 3 && clientKeyValue >= advertKeyValue)
                worth = advert.rules.worth[i];

            else if (action == 4 && clientKeyValue > advertKeyValue)
                worth = advert.rules.worth[i];

            else if (action == 5 && clientKeyValue < advertKeyValue)
                worth = advert.rules.worth[i];

            worthPresents += worth;
        }

        if (worthPresents >= 50) { // 50% - minimum for activate advert
            uint256 rewards = mathDiv(mathMul(advert.rules.maxWorth, worthPresents), 100);
            client.rewards[advert.advertId] = mathMax(rewards, advert.rules.minWorth);
            return true;
        }
        return false;
    }

    function mathMul(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function mathDiv(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    function mathMax(uint a, uint b) private constant returns (uint) {
        if (a > b) return a;
        else return b;
    }

    function createOfferWordsByAdvertType(bytes32 argAdvertType) private {
        if (!rootSearch[argAdvertType].exists) {
            advertTypes.push(argAdvertType);
            rootSearch[argAdvertType].exists = true;
        }
    }

// this code demonstrates how the advertising words were saved for search before to the latest version.
// (!for reference only!)
// todo will be deleted in next commit!
//    function recursiveAddSearchWords(
//        bytes32[] words,
//        OfferWord storage offerWord,
//        uint32 index,
//        uint256 advertId
//    )
//        private
//        returns (bytes32[])
//    {
//        if (index >= words.length) {
//            offerWord.advert.push(advertId);
//            return words;
//        }
//
//        OfferWord storage next = offerWord.offers[words[index]];
//        if (!next.exists) {
//            offerWord.keys.push(words[index]);
//            next.exists = true;
//        }
//
//        index++;
//
//        return recursiveAddSearchWords(words, next, index);
//    }
//
//    function recursiveSearchWords(bytes32[] words, OfferWord storage offerWord, uint32 index)
//        private
//        returns (bytes32[])
//    {
//        if (index >= words.length) {
//            return offerWord.keys;
//        } else {
//
//            OfferWord storage next = offerWord.offers[words[index]];
//
//            if (next.keys.length == 0 && index == words.length - 1 && index > 0
//                || next.keys.length == 0 && index < words.length - 1)
//                return new bytes32[](0);
//            else if (next.keys.length == 0)
//                return offerWord.keys;
//
//            index++;
//            return recursiveSearchWords(words, next, index);
//        }
//    }
//
//    function recursiveCollectAdvertsByWords(bytes32[] words,bytes32[] words, ignoreAdverts)
//    private
//    returns (uint256[])
//    {
//        if (index >= words.length) {
//            return offerWord.adverts;
//        } else {
//
//            bool hasNext = false;
//            uint8 index = 0;
//            Advert[] adverts;
//            OfferWord storage next;
//
//            while(!hasNext) {
//                next = offerWord.offers[words[index]];
//                adverts.push(next);
//                index++;
//            }
//
//            if (next.keys.length == 0 && index == words.length - 1 && index > 0
//                || next.keys.length == 0 && index < words.length - 1)
//                return new bytes32[](0);
//            else if (next.keys.length == 0)
//                return offerWord.keys;
//
//            index++;
//            return recursiveSearchWords(words, next, index);
//        }
//    }
}
