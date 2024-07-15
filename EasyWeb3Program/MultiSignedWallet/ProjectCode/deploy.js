const Web3 = require('web3');
   const MultiSigWallet = artifacts.require('MultiSigWallet');
   
   // 配置web3连接
   const web3 = new Web3('http://localhost:8545');
   
   // 测试用账户
   const account = '0xabc...'; // 使用的账户地址
   
   // 部署合约
   module.exports = function(deployer, network, accounts) {
     deployer.deploy(MultiSigWallet, [accounts[0], accounts[1], accounts[2]], 2, { from: account })
       .then(function(newMultiSigWallet) {
         console.log('MultiSigWallet deployed at:', newMultiSigWallet.address);
       });
   };