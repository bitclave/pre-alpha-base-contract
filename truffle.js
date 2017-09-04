module.exports = {
        migrations_directory: "./migrations",
        networks: {
                development: {
                        host: "localhost",
                        port: 8545,
                        network_id: "*", // Match any network id
                        gasPrice: 4000000000 // 4GWei
                }
        }
};
