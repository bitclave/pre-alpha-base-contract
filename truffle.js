require('babel-register');
require('babel-polyfill');

module.exports = {
    migrations_directory: "./migrations",
    networks: {
        development: {
            host: "localhost",
            port: 8545,
            network_id: "*", // Match any network id
            gas: 6700000,
            gasPrice: 40000000000 // 4GWei
        },
        ropsten: {
            host: "localhost",
            port: 8546,
            network_id: 3, //1 is the main blockchain and 2 is the old testnet, morden.
            gas: 6000000,
            gasPrice: 40000000000, // 4GWei
            from: '0x960819Ad01c6C1c4D2aC246b07Ee35129f819AC7' //my test account address for deploy
        }
    }
};
