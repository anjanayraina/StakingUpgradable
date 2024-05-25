const hre = require("hardhat");

// const StakingContract = artifacts.require("StakingContract");
async function main() {
   
    const Staking = await hre.ethers.getContractFactory('Staking')

     // Deploy the contract with constructor parameters
    const staking = await Staking.deploy(1,5);
  
     await staking.waitForDeployment();
    console.log("Staking Contract Address = ", await staking.getAddress());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });