const Web3 = require('web3');
const MultiSigWallet = artifacts.require('MultiSigWallet');

// 配置web3连接
const web3 = new Web3('http://localhost:8545');

// 实例化合约
const contractAddress = '0x123...'; // 合约地址
const multiSigWallet = new web3.eth.Contract(MultiSigWallet.abi, contractAddress);

// 测试用账户
const account1 = '0xabc...'; // 账户1
const account2 = '0xdef...'; // 账户2

// 测试存款事件
multiSigWallet.methods.deposit().send({
    from: account1,
    value: web3.utils.toWei('1', 'ether')
}).on('receipt', function(receipt) {
    console.log('Deposit event emitted:', receipt.events.Deposit);
});

// 测试提交交易
multiSigWallet.methods.submit(account2, web3.utils.toWei('0.5', 'ether'), '0x').send({
    from: account1
}).on('receipt', function(receipt) {
    console.log('Submit event emitted:', receipt.events.Submit);
});

// 测试批准交易
multiSigWallet.methods.approve(0).send({
    from: account2
}).on('receipt', function(receipt) {
    console.log('Approve event emitted:', receipt.events.Approve);
});

// 测试执行交易
multiSigWallet.methods.execute(0).send({
    from: account1
}).on('receipt', function(receipt) {
    console.log('Execute event emitted:', receipt.events.Execute);
});

// 测试撤销交易
multiSigWallet.methods.revoke(0).send({
    from: account1
}).on('receipt', function(receipt) {
    console.log('Revoke event emitted:', receipt.events.Revoke);
});
