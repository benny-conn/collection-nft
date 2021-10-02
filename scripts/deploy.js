async function main() {
  const CollectionNFT = await ethers.getContractFactory("CollectionNFT")

  // Start deployment, returning a promise that resolves to a contract object
  const collNFT = await CollectionNFT.deploy("Collection NFT", "COL") // Instance of the contract
  console.log("CollectionNFT deployed to address:", collNFT.address)
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error)
    process.exit(1)
  })
