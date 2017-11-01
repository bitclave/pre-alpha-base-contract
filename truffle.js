require('babel-register');
require('babel-polyfill');

const Provider = require('./helpers/Provider');

const ProviderMain = Provider.createMainNetwork("type here your private key from owner address");
const ProviderRopsten = Provider.createRopstenNetwork("type here your private key from owner address");
const ProviderTestRpc = Provider.createTestRpcNetwork("type here your private key from owner address");

module.exports = new NetworkConfiguration();

function NetworkConfiguration() {
    const networks = {};

    networks[Provider.DEPLOY_MAIN_NETWORK_NAME] = ProviderMain.getNetwork();
    networks[Provider.DEPLOY_ROPSTEN_NETWORK_NAME] = ProviderRopsten.getNetwork();
    networks[Provider.DEPLOY_TESTRPC_NETWORK_NAME] = ProviderTestRpc.getNetwork();

    networks['development'] = {
        host: "localhost",
        port: 8545,
        network_id: "*", // Match any network id
        gas: 6000000,
        gasPrice: 21000000000 // 2GWei
    };

    return {networks: networks}
}
