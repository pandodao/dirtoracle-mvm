import { ethers } from "hardhat";

async function main() {
  const Bls = await ethers.getContractFactory("BLS");
  const bls = await Bls.deploy();
  await bls.deployed();

  const DirtOracle = await ethers.getContractFactory(
    "DirtOracle",
    {
      libraries: {
        BLS: bls.address,
      },
    },
  );
  const dirtoracle = await DirtOracle.deploy(

  );
  await dirtoracle.deployed();

  console.log("DirtOracle deployed to:", dirtoracle.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
