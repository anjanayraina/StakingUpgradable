
// Use this script to deploy your initial contract with Upgradeable proxy

const {ethers,upgrades} = require("hardhat");
const web3 = require("web3");

async function main() {
   
      const numberOfBlocksPerSecond = 5; 
      const rewardPerBlock = web3.utils.toWei("0.0001", "ether");
      const stakingContract = "0x6Ff42b43A8f0CEA2C64b85da741675f4Cf24101e";  // contract address get from deploy1.js
      const daysAfterReward = 5; 

    const Staking = await ethers.getContractFactory('StakingContract')
    const staking = await upgrades.deployProxy(Staking,[numberOfBlocksPerSecond,rewardPerBlock,stakingContract,daysAfterReward]);
    
    await staking.waitForDeployment();

    console.log("Staking Proxy Contract deployed to : ",await staking.getAddress());
    console.log("Staking Contract implementation address is : ",await upgrades.erc1967.getImplementationAddress(await staking.getAddress()));
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });