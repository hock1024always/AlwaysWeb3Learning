// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract MultiSigWallet {
    //创建事件
    event Deposit(address indexed sender, uint amount);//存款

    event Submit(uint indexed txId);//提交交易 等待其他人批准
    event Approve(address indexed owner, uint indexed txId);//
    event Revoke(address indexed owner, uint indexed txId);//撤销交易
    event Execute(uint indexed txId);//执行交易

    struct Transaction {
        address to; //转账地址
        uint value; //转账金额
        bytes data; //转账数据
        bool executed; //是否已执行
        //bool approved; //是否批准
    }
    Transaction[] public transactions; //交易列表
    
    address[] public owners; //合约所有者 
    mapping(address => bool) public isOwner; //合约所有者地址
    
    uint public required; //最少签名数

    mapping(uint => mapping(address => bool)) public approved; //交易编号->批准账户

    //构造函数
    constructor(address[] memory _owners, uint _required) {
        require(
            _owners.length > 0, 
            "the address is empty"
        );
        require(
            _required > 0 && _required <= _owners.length,
            "the required number is invalid"
        );
    
        //使用循环将用户地址数组中的用户插入到owners数组中
        for (uint i;i<_owners.length;i++){
            address owner = _owners[i];
            require(owner!= address(0), "owner address cannot be empty");
            require(!isOwner[owner], "owner address cannot be duplicated");

            isOwner[owner] = true;
            owners.push(owner);//插入新用户，这个数据结构用于存储用户账户
        }

        required = _required;//创建合约时设置最少签名数

    }

    modifier onlyOwner() {
        require(isOwner[msg.sender], "only owner can call this function");
        _; 
    }

    modifier txExists(uint _txId){
        require(_txId < transactions.length, "transaction does not exist");
        _;
    }//交易编号小于交易列表数组长度

    modifier nonApproed(uint _txId){
        //mapping(uint => mapping(address => bool)) public approved;
        require(!approved[_txId][msg.sender],"only nonApproved TX can call this function" );//?
        _;
    }//使用到当时存储的待批准交易列表，判断当前用户是否已经批准过该交易

    modifier notExcuted(uint _txId){
        require(!transactions[_txId].executed, "transaction has been executed"); 
        _;
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }//receive 在接收以太币时自动调用

    //外部可调用函数 只有合约所有者可以调用
    function submit(address _to, uint _value, bytes calldata _data)
        external
    onlyOwner
    {
        transactions.push(Transaction({
            to: _to,
            value: _value,
            data: _data,
            executed: false//尚未被审核的交易
        }));
    
        emit Submit(transactions.length - 1);//提交序号 原理和数组一样
    }

    function approve(uint _txId)
        external
    onlyOwner
    txExists(_txId)
    nonApproed(_txId)
    notExcuted(_txId)
    {
        approved[_txId][msg.sender] = true;
        emit Approve(msg.sender, _txId);
    }

    function _getApprovalCount(uint _txId) private view returns(uint count)    {
        for(uint i;i < owners.length;i++){
            if(approved[_txId][owners[i]]){
                count++;
            }
        }
        //隐式返回值 不需要return语句
    }

    //执行交易
    function excute(uint _txId) external txExists(_txId) notExcuted(_txId){

        require(_getApprovalCount(_txId) >= required, "not enough approvals");     
        Transaction storage transaction = transactions[_txId];
    
        transaction.executed = true;

        (bool success, ) = transaction.to.call{value: transaction.value}(transaction.data);
        require(success, "transfer failed");

        emit Execute(_txId);

    }

    //撤销交易
    function revoke(uint _txId) external 
    onlyOwner 
    txExists(_txId) 
    //nonApproed(_txId) 
    notExcuted(_txId)
    {
        require(approved[_txId][msg.sender], "only approved TX can be revoked");
        approved[_txId][msg.sender] = false;
        emit Revoke(msg.sender, _txId);
    } 
}
