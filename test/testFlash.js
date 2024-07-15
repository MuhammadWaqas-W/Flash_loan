const { expect, assert } = require("chai");
const { ethers } = require("hardhat");
const { fundContract } = require("../utils/utilities");

const {
    abi,
} = require("../artifacts/contracts/interfaces/IERC20.sol/IERC20.json");

const provider = waffle.provider;

describe("FlashLoan Contract", () => {
    let FLASHLOAN,
        BORROW_AMOUNT,
        FUND_AMOUNT,
        initialFundingHuman,
        txArbitrage;


    const DECIMALS = 18;

    const BUSD_WHALE = "0x8fe348f2f890046719aacea910f01d772dc20a65";
    const BUSD = "0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56";
    const CAKE = "0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82";
    const CROX = "0x2c094F5A7D1146BB93850f629501eB749f6Ed491";


    const busdInstance = new ethers.Contract(BUSD, abi, provider);
    const cakeInsatnce = new ethers.Contract(CAKE, abi, provider);
    const croxInstance = new ethers.Contract(CROX, abi, provider);

    beforeEach(async () => {

        // Ensure that the WHALE has a balance
        const whale_balance = await provider.getBalance(BUSD_WHALE);
        expect(whale_balance).not.equal("0");

        //deploy 
        const FlashLoan = await ethers.getContractFactory("FlashLoan");
        FLASHLOAN = await FlashLoan.deploy();
        await FLASHLOAN.deployed();

        const borrowAmountHuman = "1";
        BORROW_AMOUNT = ethers.utils.parseUnits(borrowAmountHuman, DECIMALS);

        initialFundingHuman = "100";
        FUND_AMOUNT = ethers.utils.parseUnits(initalFundingHuman, DECIMALS);

        await fundContract(
            busdInstance,
            BUSD_WHALE,
            FLASHLOAN.address,
            initialFundingHuman
        )
    })

    describe("Arbitrage Execution", () => {

        it("Ensures the contract is Funded", async () => {
            const flashloanBalance = await FLASHLOAN.getBalanceOfToken(BUSD);
            const flashloanBalanceHuman = ethers.utils.formatUnits(flashloanBalance, DECIMALS);
            expect(Number(flashloanBalanceHuman)).equal(Number(initialFundingHuman));
            //till now if test is Successful then amount is transfered  to the Contract successfully


        })
        it("execute the arbitrage",async()=>{
            txArbitrage=await FLASHLOAN.initateArbitrage(
                BUSD,BORROW_AMOUNT
            )
            assert(txArbitrage)

            const contractBalanceBUSD= await FLASHLOAN.getBalanceOfToken(BUSD);
            const formattedBalBUSD= Number(
                ethers.utils.formatUnits(contractBalanceBUSD,DECIMALS)
            );
            console.log("Balance of BUSD: "+ formattedBalBUSD);

            const contractBalanceCROX= await FLASHLOAN.getBalanceOfToken(CROX);
            const formattedBalCROX= Number(
                ethers.utils.formatUnits(contractBalanceCROX,DECIMALS)
            );
            console.log("Balance of BUSD: "+ formattedBalCROX);

            

        })
    })

})

