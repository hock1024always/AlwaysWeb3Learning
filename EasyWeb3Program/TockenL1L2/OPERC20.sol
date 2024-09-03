// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 引入 ERC20 标准接口定义文件
import "./ERC20.sol";


// 定义 IERC165 接口
interface IERC165{
    // 定义一个函数，用于检查合约是否支持给定的接口ID
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// 定义 IOptimismMIntableface 接口，继承自 IERC165
interface IOptimismMIntableERC20 is IERC165{
    // 定义一个函数，用于获取远程代币 合约地址
    function remoteTolen() external view returns (address);
    
    // 定义一个函数，用于获取本地 bridge 合约地址
    function bridge() external view returns (address);
    
    // 定义一个函数，用于在指定地址铸造指定数量的 Token
    function mint(address dst, uint256 amount) external;
    
    // 定义一个函数，用于在指定地址销毁指定数量的 Token
    function burn(address src, uint256 amount) external;
    
}

// 定义 OPERC20 合约，继承自 ERC20 和 IOptimismMIntableface 接口
contract OPERC20 is ERC20, IOptimismMIntableERC20{
    // 定义一个不可变的公共变量 remoteToken，用于存储远程 Token 合约地址
    address public immutable remoteToken;
    
    // 定义一个不可变的公共变量 bridge，用于存储 bridge 合约地址
    address public immutable bridge;
    
    // 定义一个 Mint 事件，用于在铸造 Token 时发出通知
    event Mint(address indexed account, uint256 amount);
    
    // 定义一个 Burn 事件，用于在销毁 Token 时发出通知
    event Burn(address indexed account, uint256 amount);
    
    // 定义一个名为 onlyBridge 的修饰符，用于限制只有 bridge 合约才能调用某些函数
    modifier onlyBridge{
        // 检查调用者是否为 bridge 合约
        require(msg.sender == bridge, "Only bridge can call this function");
        // 执行被修饰的函数体
        _;
    }
    
    // 构造函数，在部署合约时初始化 remoteToken 和 bridge 变量
    constructor(address _remoteToken, address _bridge){
        // 设置 remoteToken 变量
        remoteToken = _remoteToken;
        // 设置 bridge 变量
        bridge = _bridge;
    }
    
    // 实现 IERC165 接口的 supportsInterface 函数
    function supportsInterface(bytes4 _interfaceId) external pure returns(bool){
        // 获取 IERC165 接口的接口 ID，并将其存储在变量 iface 中
        bytes4 ifacel = type(IERC165).interfaceId;
        
        // 获取 IOptimismMIntableERC20 接口的接口 ID，并将其存储在变量 iface3 中
        bytes4 iface3 = type(IOptimismMIntableERC20).interfaceId;
        
        // 返回调用者传入的接口ID是否等于 IERC165 或 IOptimismMIntableERC20 的接口ID
        return _interfaceId == ifacel || _interfaceId == iface3;
    }
    
    // 实现了一个名为 mint 的外部函数，用于铸造 Token
    function mint(address dst, uint256 amount) external override{
        // 调用父类 ERC20 的 _mint 函数，在指定地址上铸造指定数量的 Token
        _mint(dst, amount);
        
        // 触发一个名为 Mint 的事件，并记录接收地址和铸造数量的日志
        emit Mint(dst, amount);
    }
    
    // 实现了一个名为 burn 的外部函数，用于销毁 Token
    function burn(address src, uint256 amount) external override{
        // 调用父类 ERC20 的 _burn 函数，从指定地址上销毁指定数量的 Token
        _burn(src, amount);
        
        // 触发一个名为 Burn 的事件，并记录销毁地址和销毁数量的日志
        emit Burn(src, amount);
    }
    
}

