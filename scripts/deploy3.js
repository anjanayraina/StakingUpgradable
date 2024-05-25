
// Use this script only when you want to upgrade your contract

const { ethers,upgrades } = require("hardhat");
const proxyAddress = "0x77650231311f5BfeB3c1B97A5c84500c9543edF5";  // contract address get from deploy2.js

async function main() {
   
    console.log("Deploying UpdateStaking  contract...");
       
    const UpdateStaking = await ethers.getContractFactory ('StakingContractV2')
    const updatestaking = await upgrades.upgradeProxy(proxyAddress,UpdateStaking);
       await updatestaking.waitForDeployment();

       console.log("UpdateStaking Proxy Contract ( Must be Same ) deployed to : ",await updatestaking.getAddress());
       console.log("UpdateStaking Contract implementation address is : ",await upgrades.erc1967.getImplementationAddress(await updatestaking.getAddress()));

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });


  // Staking Proxy Contract deployed to :  0x77650231311f5BfeB3c1B97A5c84500c9543edF5
  // Staking Contract implementation address is :  0x677226e988dfd8c17fdADb3e1467beF14b1CEa7d