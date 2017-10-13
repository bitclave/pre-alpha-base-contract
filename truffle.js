require('babel-register');
require('babel-polyfill');

module.exports = {
    migrations_directory: "./migrations",
    networks: {
        development: {
            host: "localhost",
            port: 8545,
            network_id: "*", // Match any network id
            gas: 6000000,
            gasPrice: 4700000000 // 4GWei
        }
    }
};
