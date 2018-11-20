var caelumToken = artifacts.require("./mockToken.sol");
var caelumLottery = artifacts.require("./CaelumLottery.sol");

let catchRevert = require("./exceptions.js").catchRevert;

contract('CaelumLottery', function(accounts) {
  var Token
  var Lottery

  const timeTravel = function (time) {
  return new Promise((resolve, reject) => {
    web3.currentProvider.sendAsync({
      jsonrpc: "2.0",
      method: "evm_increaseTime",
      params: [time], // 86400 is num seconds in day
      id: new Date().getTime()
    }, (err, result) => {
      if(err){ return reject(err) }
      return resolve(result)
    });
  })
}

  const mineBlock = function () {
    return new Promise((resolve, reject) => {
      web3.currentProvider.sendAsync({
        jsonrpc: "2.0",
        method: "evm_mine"
      }, (err, result) => {
        if(err){ return reject(err) }
        return resolve(result)
      });
    })
  }

  it("can deploy ", async function () {
    Token = await caelumToken.deployed();
    Lottery = await caelumLottery.deployed();
  })

  it('Owner can (re)set a lottery', async function() {
      let doAction = await Lottery.resetLottery(1, 5);
  });

  it('User 1 can send 0.05 ETH', async function() {
      let doAction = await web3.eth.sendTransaction({value: web3.toWei(0.05, "ether"), from: accounts[1], to: Lottery.address});
  });

  it('User 2 can send 0.05 ETH', async function() {
      let doAction = await web3.eth.sendTransaction({value: web3.toWei(0.05, "ether"), from: accounts[2], to: Lottery.address});
  });

  it('User 3 can send 0.05 ETH', async function() {
      let doAction = await web3.eth.sendTransaction({value: web3.toWei(0.05, "ether"), from: accounts[3], to: Lottery.address});
  });

  it('User 4 can send 0.05 ETH', async function() {
      let doAction = await web3.eth.sendTransaction({value: web3.toWei(0.05, "ether"), from: accounts[4], to: Lottery.address});
  });

  it('User 5 can send 0.05 ETH', async function() {
      let doAction = await web3.eth.sendTransaction({value: web3.toWei(0.05, "ether"), from: accounts[5], to: Lottery.address});
  });

  it('Forward 1 days', async function() {

    await timeTravel(86400 * 1);
    await mineBlock();
  });

  it('Anyone can close the lottery after mininum tickets and date rule', async function() {
      let doAction = await Lottery.announceWinners();
  });

  it('Should have 3 winners.', async function() {
      let doAction1 = await Lottery.WINNER1();
      let doAction2 = await Lottery.WINNER2();
      let doAction3 = await Lottery.WINNER3();

      console.log(doAction1.valueOf(), doAction2.valueOf(), doAction3.valueOf());
  });

  //await catchRevert(mainToken.depositCollateral(mainSwapToken.address, 5000 * 1e8));


})
