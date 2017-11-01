const Gateway = artifacts.require("./Gateway.sol");
const PreCATToken = artifacts.require("./PreCATToken.sol");
const BaseContract = artifacts.require("./BaseContract.sol");
const SearchContract = artifacts.require("./SearchContract.sol");
const Provider = require('../helpers/Provider');

module.exports = function (deployer, network) {
    if (Provider.DEPLOY_NETWORK_NAMES_LIST.indexOf(network) === -1) {
        return;
    }

    function Cortege() {
        this.gateway = null;
        this.base = null;
        this.search = null;
        this.tokens = null;
        this.getNext = function () {
            return new Promise(function (resolve, reject) {
                resolve(this);
            }.bind(this));
        }
    }

    deployer.then(function () {
        return Gateway.new().then(function (gateway) {
            console.log('Gateway deployed');
            const cortege = new Cortege();
            cortege.gateway = gateway;
            return cortege.getNext();
        })

    }).then(function (cortege) {
        return BaseContract.new().then(function (baseContract) {
            console.log('BaseContract deployed');
            cortege.base = baseContract;
            return cortege.getNext();
        });

    }).then(function (cortege) {
        return SearchContract.new(cortege.base.address).then(function (searchContract) {
            console.log('SearchContract deployed');
            cortege.search = searchContract;
            return cortege.getNext();
        });

    }).then(function (cortege) {
        return PreCATToken.new().then(function (tokens) {
            console.log('PreCATToken deployed');
            cortege.tokens = tokens;
            return cortege.getNext();
        });
    }).then(function (cortege) {
        return cortege.gateway.setBaseContract(cortege.base.address).then(function () {
            console.log('gateway.setBaseContract successful');
            return cortege.getNext();
        })
    }).then(function (cortege) {
        return cortege.base.setTokensContract(cortege.tokens.address).then(function () {
            console.log('base.setTokensContract successful');
            return cortege.getNext();
        })
    }).then(function (cortege) {
        return cortege.base.setSearchContract(cortege.search.address).then(function () {
            console.log('base.setSearchContract successful');
            return cortege.getNext();
        })
    }).then(function (cortege) {
        return cortege.tokens.owner().then(function (ownerAddress) {
            console.log('OWNER', ownerAddress);
            console.log('GATEWAY CONTRACT:', cortege.gateway.address);
            console.log('BASE CONTRACT:', cortege.base.address);
            console.log('SEARCH CONTRACT:', cortege.search.address);
            console.log('TOKENS CONTRACT:', cortege.tokens.address);
        });
    });

};
