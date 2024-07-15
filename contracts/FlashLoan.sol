 // SPDX-License-Identifier: UNLICENSED
// pragma solidity >=0.6.0;

// // Uncomment this line to use console.log
// // import "hardhat/console.sol";
// import "./interfaces/IERC20.sol";
// import "./interfaces/IUniswapV2Factory.sol";
// import "./interfaces/IUniswapV2Pair.sol";
// import "./interfaces/IUniswapV2Router01.sol";
// import "./interfaces/IUniswapV2Router02.sol";
// import "./libraries/SafeERC20.sol";
// import "./libraries/UniswapV2Library.sol";

// contract Flash_loan {
//     using SafeERC20 for IERC20;

//     address private constant pancake_factory =
//         "0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73";
//     address private constant pancake_router =
//         "0x10ED43C718714eb63d5aA57B78B54704E256024E";

//     //Token_address
//     address private constant BUSD =
//         "0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56";
//     address private constant WBNB =
//         "0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c";
//     address private constant CROX =
//         "0x2c094F5A7D1146BB93850f629501eB749f6Ed491";
//     address private constant CAKE =
//         "0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82";

//     uint256 private deadline = block.timestamp + 1 days;
//     uint256 private constant MAX_INT =
//         "115792089237316195423570985008687907853269984665640564039457584007913129639935";

//     function initateArbitrage(address _tokenborrow, uint256 _amount) private {
//         IERC20(BUSD).safeApprove(address(pancake_router), MAX_INT); //full authority on my behalf (contract) to spend tokens
//         IERC20(CROX).safeApprove(address(pancake_router), MAX_INT); //full authority on my behalf to get tokens
//         IERC20(CAKE).safeApprove(address(pancake_router), MAX_INT); //full authority on my behalf to get tokens

//         address pair = IUniswapV2Factory(pancake_factory).getPair(
//             _tokenborrow,
//             WBNB
//         ); //liquidity pool which deals with busd/WBNB address
//         require(pair != address(0), "Pool Not exist");

//         address token0 = IUniswapV2Pair(pair).token0();
//         address token1 = IUniswapV2Pair(pair).token1();

//         uint amount0Out = _tokenborrow == token0 ? _amount : 0; //wbnb
//         uint amount1Out = _tokenborrow == token1 ? _amount : 0; //busd

//         bytes memory data = abi.encode(_tokenborrow, _amount, msg.sender);

//         //amount1 tokens will be transfered to this contract address for trading
//         IUniswapV2Pair(pair).swap(amount0Out, amount1Out, address(this), data); //in the provided liquidity pool swap the tokens now
//     }

//     function pancakeCall(
//         address _sender,
//         uint _amount0,
//         uint _amount1,
//         bytes calldata _data
//     ) external {
//         address token0 = IUniswapV2Pair(msg.sender).token0();
//         address token1 = IUniswapV2Pair(msg.sender).token1();
//         address pair = IUniswapV2Factory(pancake_factory).getPair(
//             token0,
//             token1
//         ); //getting the pool address again
//         require(msg.sender == pair, "Pair Doesn't match");
//         require(_sender == address(this), "sender don't match");

//         (address busdBorrow, uint amount, address account) = abi.decode(
//             _data,
//             (address, uint, address)
//         );

//         //fee calculation for pancake
//         uint feee = ((amount * 3) / 997) + 1;

//         uint repayamount = amount + fee;

//         uint loanamount = _amount0 > 0 ? _amount0 : _amount1;

//         //Trinagular Arbitrage
//         uint trade1coin = placeTrade(BUSD, CROX, loanamount);
//         uint trade2coin = placeTrade(CROX, CAKE, trade1coin);
//         uint trade3coin = placeTrade(CAKE, BUSD, trade2coin);

//         bool result = checkresult(repayamount, trade3coin); //here we will check whether we get some profit or not
//         require(result, "Arbitrage is not profitable");
//         IERC20(BUSD).transfer(account, trade3coin - repayamount); //profit amount send to contract who beging transction
//         IERC20(busdBorrow).transfer(pair, repayamount); //original amount send to pool
//     }
//     function checkresult(
//         uint256 repay,
//         uint256 _acquireCoin
//     ) private returns (bool) {
//         return _acquireCoin > repay;
//     }
//     //this will provide the toToken (Tokens) equal to value of fromToken
//     function placeTrade(
//         address fromToken,
//         address toTOken,
//         uint _amountIn
//     ) private returns (uint256) {
//         address pair = IUniswapV2Factory(pancake_factory).getPair(
//             fromToken,
//             toTOken
//         ); //getting pool address
//         require(pair!=address(0),"Pool does not exist");
//         address[] memory path =new address[](2);//array of length2
//         path[0]=fromToken;
//         path[1]=toTOken;

//         uint256 amountRequired=IUniswapV2Router01(pancake_factory).getAmountOut(_amountIn,path[1]); //this will tells how much amount of second token we will get

//         uint amountReceived= IUniswapV2Router01(pancake_router).swapExactTokensForTokens(_amountIn,amountRequired,address(this),deadline)[1];
        
//         require(amountReceived>0, "No tokens received");
//         return amountReceived;



//     }

//     function getBalanceofToken(address _address) public view returns(uint256){
//         return IERC20(_address).balanceOf(address(this));
//     }
// }

// SPDX-License-Identifier: UNLICENSED
pragma solidity  >=0.6.0;

// Uniswap interface and library imports
import "./interfaces/IUniswapV2Factory.sol";
import "./interfaces/IUniswapV2Pair.sol";
import "./interfaces/IUniswapV2Router01.sol";
import "./interfaces/IUniswapV2Router02.sol";
import "./interfaces/IERC20.sol";
import "./libraries/UniswapV2Library.sol";
import "./libraries/SafeERC20.sol";
import "hardhat/console.sol";

contract FlashLoan {
     using SafeERC20 for IERC20;
    // Factory and Routing Addresses
    address private constant PANCAKE_FACTORY =
        0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
    address private constant PANCAKE_ROUTER =
        0x10ED43C718714eb63d5aA57B78B54704E256024E;

    // Token Addresses
    address private constant BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address private constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address private constant CROX = 0x2c094F5A7D1146BB93850f629501eB749f6Ed491;
    address private constant CAKE = 0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82;

    uint256 private deadline = block.timestamp + 1 days;
    uint256 private constant MAX_INT =
        115792089237316195423570985008687907853269984665640564039457584007913129639935;
    
    function checkResult(uint _repayAmount,uint _acquiredCoin) pure private returns(bool){
        return _acquiredCoin>_repayAmount;
    }
    
     // GET CONTRACT BALANCE
    // Allows public view of balance for contract
    function getBalanceOfToken(address _address) public view returns (uint256) {
        return IERC20(_address).balanceOf(address(this));
    }


    function placeTrade(address _fromToken,address _toToken,uint _amountIn) private returns(uint){
        address pair = IUniswapV2Factory(PANCAKE_FACTORY).getPair(
            _fromToken,
            _toToken
        );
        require(pair != address(0), "Pool does not exist");

        // Calculate Amount Out
        address[] memory path = new address[](2);
        path[0] = _fromToken;
        path[1] = _toToken;

        uint256 amountRequired = IUniswapV2Router01(PANCAKE_ROUTER)
            .getAmountsOut(_amountIn, path)[1];

    
        uint256 amountReceived = IUniswapV2Router01(PANCAKE_ROUTER)
            .swapExactTokensForTokens(
                _amountIn, 
                amountRequired, 
                path,
                address(this),
                deadline 
            )[1];


        require(amountReceived > 0, "Transaction Abort");

        return amountReceived;
    }

    function initateArbitrage(address _busdBorrow,uint _amount) external{
         IERC20(BUSD).safeApprove(address(PANCAKE_ROUTER),MAX_INT);
         IERC20(CROX).safeApprove(address(PANCAKE_ROUTER),MAX_INT);
         IERC20(CAKE).safeApprove(address(PANCAKE_ROUTER),MAX_INT);
         
         //liquidity pool of BUSD and WBNB
         address pair = IUniswapV2Factory(PANCAKE_FACTORY).getPair(
            _busdBorrow,
            WBNB
         );

         require(pair!=address(0),"Pool does not exist");
         
         address token0 = IUniswapV2Pair(pair).token0();//WBNB
         address token1 = IUniswapV2Pair(pair).token1();//BUSD

         uint amount0Out = _busdBorrow==token0?_amount:0;
         uint amount1Out = _busdBorrow==token1?_amount:0; //BUSD Amount
         
         bytes memory data = abi.encode(_busdBorrow,_amount,msg.sender);
         IUniswapV2Pair(pair).swap(amount0Out, amount1Out, address(this), data);
    }

    function pancakeCall(
        address _sender,
        uint256 _amount0,
        uint256 _amount1,
        bytes calldata _data
    ) external {
        // Ensure this request came from the contract
        address token0 = IUniswapV2Pair(msg.sender).token0();
        address token1 = IUniswapV2Pair(msg.sender).token1();
        address pair = IUniswapV2Factory(PANCAKE_FACTORY).getPair(
            token0,
            token1
        );
        require(msg.sender == pair, "The sender needs to match the pair");
        require(_sender == address(this), "Sender should match the contract");

        // Decode data for calculating the repayment
        (address busdBorrow, uint256 amount, address myAddress) = abi.decode(
            _data,
            (address, uint256, address)
        );

        // Calculate the amount to repay at the end
        uint256 fee = ((amount * 3) / 997) + 1;
        uint256 repayAmount = amount + fee;

        // DO ARBITRAGE

        // Assign loan amount
        uint256 loanAmount = _amount0 > 0 ? _amount0 : _amount1;

        // Place Trades
        uint256 trade1Coin = placeTrade(BUSD, CROX, loanAmount);
        uint256 trade2Coin = placeTrade(CROX, CAKE, trade1Coin);
        uint256 trade3Coin = placeTrade(CAKE, BUSD, trade2Coin);

        // Check Profitability
        bool profCheck = checkResult(repayAmount, trade3Coin);
        require(profCheck, "Arbitrage not profitable");

        // Pay Myself
        IERC20 otherToken = IERC20(BUSD);
        otherToken.transfer(myAddress, trade3Coin - repayAmount);

        // Pay Loan Back
        IERC20(busdBorrow).transfer(pair, repayAmount);
    }



}