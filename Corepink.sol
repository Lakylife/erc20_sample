// SPDX-License-Identifier: MIT

/* _____ ____  _____  ______   _____ _____ _   _ _  __
  / ____/ __ \|  __ \|  ____| |  __ \_   _| \ | | |/ /
 | |   | |  | | |__) | |__    | |__) || | |  \| | ' / 
 | |   | |  | |  _  /|  __|   |  ___/ | | | . ` |  <  
 | |___| |__| | | \ \| |____ _| |    _| |_| |\  | . \ 
  \_____\____/|_|  \_\______(_)_|   |_____|_| \_|_|\_\

  Website: https://core.pink
  Blockchain: https://blockchain.core.pink
  App: https://app.core.pink
  Wallet: https://wallet.core.pink
  Explorer: https://explorer.core.pink
  Docs: https://docs.core.pink

  2025 Start Blockchain $CORE

  Telegram miniApp: @thecryptofee_bot
  Twitter: @thecorepink
  Telegram: @thecorepink
  Telegram support: @corepinksupport
*/                                        

pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function symbol() external view virtual override returns (string memory) {
        return _symbol;
    }

    function name() external view virtual override returns (string memory) {
        return _name;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return _totalSupply;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function transfer(address to, uint256 amount) external virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) external virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _totalSupply += amount;
        unchecked {
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            _totalSupply -= amount;
        }
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            _balances[to] += amount;
        }
        emit Transfer(from, to, amount);
    }
}

contract Corepink is ERC20, Ownable {
    address public _rewardWallet = 0x58ad75766cd7a9f41bE2C873DBaB985428C976aE;
    address public _marketingWallet = 0xc84A05aE3054D15A20571D02Fc1E37a876242D5D;

    uint256 public _feeBuyTotal = 5;
    uint256 public _feeBuyReward = 1;
    uint256 public _feeBuyMK = 1;
    uint256 public _feeBuyLP = 3;

    uint256 public _feeSellTotal = 5;
    uint256 public _feeSellReward = 0;
    uint256 public _feeSellMK = 2;
    uint256 public _feeSellLP = 3;

    uint256 public constant MAX_SUPPLY = 14_000_000 * 10 ** 18;
    uint256 public _maxTokens = 100 * 10 ** decimals();

    uint256 private _tempReward = 0;
    uint256 private _tempMK = 0;
    uint256 private _tempLP = 0;

    IUniswapV2Router public swapRouter;
    address public swapPair;

    uint256 public constant STAKING_PERIOD = 150 * 365 days;
    uint256 public constant STAKING_REWARD = 4_000_000 * 10 ** 18;
    uint256 public stakingStartTime;
    uint256 public lastHalvingTime;

    mapping(address => uint256) public stakingBalance;
    mapping(address => uint256) public lastClaimTime;

    enum LockPeriod { None, ThreeMonths, SixMonths, TwelveMonths }
    enum Flag { None, Sell, Buy }

    struct Stake {
        uint256 amount;
        LockPeriod period;
        uint256 startTime;
    }

    mapping(address => Stake[]) public stakes;

    constructor() ERC20("Core Pink", "CORE") {
        uint256 startSupply = 10_000_000 * 10 ** decimals();
        _mint(msg.sender, startSupply);

        IUniswapV2Router _uniswapRouter = IUniswapV2Router(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        swapPair = IUniswapV2Factory(_uniswapRouter.factory())
            .createPair(address(this), _uniswapRouter.WETH());

        swapRouter = _uniswapRouter;
        
        _approve(msg.sender, address(swapRouter), type(uint256).max);
        _approve(address(this), address(swapRouter), type(uint256).max);

        stakingStartTime = block.timestamp;
        lastHalvingTime = block.timestamp;
    }

    function stakeTokens(uint256 amount, LockPeriod period) external {
        require(amount > 0, "Amount must be greater than zero");
        require(period != LockPeriod.None, "Lock period must be specified");

        super._transfer(msg.sender, address(this), amount);

        stakes[msg.sender].push(Stake({
            amount: amount,
            period: period,
            startTime: block.timestamp
        }));

        stakingBalance[msg.sender] += amount;
    }

    function claimRewards() external {
        uint256 totalReward = 0;

        for (uint256 i = 0; i < stakes[msg.sender].length; i++) {
            Stake storage stake = stakes[msg.sender][i];
            if (block.timestamp >= stake.startTime + _getLockTime(stake.period)) {
                uint256 reward = _calculateStakingReward(stake);
                totalReward += reward;
                stake.startTime = block.timestamp;
            }
        }

        if (totalReward > 0) {
            _mint(msg.sender, totalReward);
        }

        lastClaimTime[msg.sender] = block.timestamp;
    }

    function _calculateStakingReward(Stake storage stake) internal view returns (uint256) {
        uint256 rewardRate = _getRewardRate(stake.period);
        uint256 reward = (stake.amount * rewardRate * (block.timestamp - stake.startTime)) / 10**decimals();
        return reward;
    }

    function _getLockTime(LockPeriod period) internal pure returns (uint256) {
        if (period == LockPeriod.ThreeMonths) {
            return 90 days;
        } else if (period == LockPeriod.SixMonths) {
            return 180 days;
        } else if (period == LockPeriod.TwelveMonths) {
            return 365 days;
        } else {
            return 0;
        }
    }

    function _getRewardRate(LockPeriod period) internal view returns (uint256) {
        uint256 baseRate = STAKING_REWARD / STAKING_PERIOD;
        uint256 halvingCount = (block.timestamp - stakingStartTime) / (4 * 365 days);
        uint256 currentRate = baseRate / (2**halvingCount);

        if (period == LockPeriod.ThreeMonths) {
            return currentRate;
        } else if (period == LockPeriod.SixMonths) {
            return currentRate * 2;
        } else if (period == LockPeriod.TwelveMonths) {
            return currentRate * 3;
        } else {
            return 0;
        }
    }

    function _transfer(address from, address to, uint256 amount) internal override {
        uint256 taxAmount = 0;
        Flag flag = Flag.None;

        if (to == swapPair) {
            taxAmount = amount * _feeSellTotal / 100;
            flag = Flag.Sell;
        } else if (from == swapPair) {
            taxAmount = amount * _feeBuyTotal / 100;
            flag = Flag.Buy;
        }

        super._transfer(from, to, amount - taxAmount);
        
        if (taxAmount > 0) {
            if(flag == Flag.Sell){
                _tempLP += taxAmount * _feeSellLP / _feeSellTotal;
                _tempMK += taxAmount * _feeSellMK / _feeSellTotal;
                _tempReward += taxAmount * _feeSellReward / _feeSellTotal;
            }
            else{
                _tempLP += taxAmount * _feeBuyLP / _feeBuyTotal;
                _tempMK += taxAmount * _feeBuyMK / _feeBuyTotal;
                _tempReward += taxAmount * _feeBuyReward / _feeBuyTotal;
            }
            super._transfer(from, address(this), taxAmount);
        }

        if(_tempLP > _maxTokens) {
            _swapAndLiquify();
        }

        _updateStaking(from);
        _updateStaking(to);
    }

    function _updateStaking(address account) internal {
        if (stakingBalance[account] > 0) {
            uint256 reward = _calculateStakingReward(account);
            if (reward > 0) {
                _mint(account, reward);
            }
        }
        lastClaimTime[account] = block.timestamp;
    }

    function _calculateStakingReward(address account) internal view returns (uint256) {
        if (stakingBalance[account] == 0 || block.timestamp <= lastClaimTime[account]) {
            return 0;
        }
        uint256 timeStaked = block.timestamp - lastClaimTime[account];
        uint256 rewardRate = STAKING_REWARD / STAKING_PERIOD;
        uint256 reward = (stakingBalance[account] * timeStaked * rewardRate) / 10**decimals();
        return reward;
    }

    function _swapAndLiquify() private {
        _swapTokensForEth(_tempReward / 2);
        uint256 balance = address(this).balance;
        _addLiquidity(
            _tempReward / 2,
            balance
        );

        super._transfer(address(this), _rewardWallet, _tempReward);
        super._transfer(address(this), _marketingWallet, _tempMK);
        
        _tempLP = 0;
        _tempMK = 0;
        _tempReward = 0;
    }

    function _swapTokensForEth(uint256 tokenAmount) private  {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = swapRouter.WETH();
        swapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            (block.timestamp)
        );
    }

    function _addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        swapRouter.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            owner(),
            block.timestamp
        );
    }

    function setRewardWallet(address newWallet) external onlyOwner {
        _rewardWallet = newWallet;
    }

    function setMarketingWallet(address newWallet) external onlyOwner {
        _marketingWallet = newWallet;
    }

    function setMinTokens(uint256 newValue) external onlyOwner {
        _maxTokens = newValue * 10 ** decimals();
    }

    function editBuyFees(
        uint256 __feeBuyReward,
        uint256 __feeBuyMK,
        uint256 __feeBuyLP
    ) external onlyOwner {
        _feeBuyReward = __feeBuyReward;
        _feeBuyMK = __feeBuyMK;
        _feeBuyLP = __feeBuyLP;
        _feeBuyTotal = __feeBuyReward + __feeBuyMK + __feeBuyLP;
    }

    function editSellFees(
        uint256 __feeSellReward,
        uint256 __feeSellMK,
        uint256 __feeSellLP
    ) external onlyOwner {
        _feeSellReward = __feeSellReward;
        _feeSellMK = __feeSellMK;
        _feeSellLP = __feeSellLP;
        _feeSellTotal = __feeSellReward + __feeSellMK + __feeSellLP;
    }
}
