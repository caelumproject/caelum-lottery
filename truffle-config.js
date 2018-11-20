module.exports = {
    networks: {
        development: {
            host: "localhost",
            port: 7545,
            network_id: "*",
            gas: 9000000
        }
    },
 solc: {
   optimizer: {
     enabled: true,
     runs: 200
   }
 }
};
