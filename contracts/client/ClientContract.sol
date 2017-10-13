pragma solidity ^0.4.0;

import '../client/Client.sol';


contract ClientContract is Client {

    address baseContract;
    address searchContract;

    function ClientContract(address _baseContract, address _searchContract) {
        baseContract = _baseContract;
        searchContract = _searchContract;
    }

    function getData(bytes32[] keys) public constant returns (bytes32[]) {
        bytes32[] memory result = new bytes32[](keys.length);

        for(uint i = 0; i < keys.length; i++) {
            result[i] = data[keys[i]];
        }

        return result;
    }

    function setData(bytes32[] keys, bytes32[] values) onlyOwner public {
        require(keys.length == values.length);

        for (uint i = 0; i < keys.length; i++) {
            data[keys[i]] = values[i];
        }
    }

    function getRewardByOffer(address offerAddress) public constant returns (uint256) {
        return rewardOffers[offerAddress];
    }

    function setRewardByOffer(address offerAddress, uint256 reward) public {
        require(msg.sender == baseContract || msg.sender == searchContract);

        if (existRewardAddress(offerAddress)) {
            rewardOffersAddresses.push(offerAddress);
        }
        rewardOffers[offerAddress] = reward;
    }

    function existRewardAddress(address advert) private constant returns (bool) {
        for (uint i = 0; i < rewardOffersAddresses.length; i++) {
            if (rewardOffersAddresses[i] == advert) {
                return true;
            }
        }

        return false;
    }

    function clearRewards() onlyOwner external {
        for (uint i = 0; i < rewardOffersAddresses.length; i++) {
            rewardOffers[rewardOffersAddresses[i]] = 0;
        }

        delete rewardOffersAddresses;
        rewardOffersAddresses.length = 0;
    }

}
