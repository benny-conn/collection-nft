const { expect } = require("chai")
const { ethers } = require("hardhat")
const { utils } = require("ethers")

describe("CollectionNFT", function () {
  let Contract
  let contract
  let TestContract
  let testContract

  beforeEach(async function () {
    Contract = await ethers.getContractFactory("CollectionNFT")
    contract = await Contract.deploy("Collection NFT", "COL")
    TestContract = await ethers.getContractFactory("TestNFT")
    testContract = await TestContract.deploy("Test", "T")
  })

  it("Collectionizes a few Test NFTs and burns them under a different address", async function () {
    const [them, otherThem] = await ethers.getSigners()
    for (let i = 0; i < 10; i++) {
      await testContract.mint(them.address, i)
    }

    await testContract.connect(them).setApprovalForAll(contract.address, true)

    await contract
      .connect(them)
      .mint(
        [
          testContract.address,
          testContract.address,
          testContract.address,
          testContract.address,
          testContract.address,
          testContract.address,
          testContract.address,
          testContract.address,
          testContract.address,
          testContract.address,
        ],
        [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
      )
    const uri = await contract.tokenURI(0)
    console.log("URI: ", uri)

    const result = await contract.getNFTsInCollection(0)
    console.log("NFTs in Collection NFT", result)

    await contract
      .connect(them)
      ["safeTransferFrom(address,address,uint256)"](
        them.address,
        otherThem.address,
        0
      )
    await contract.connect(otherThem).burn(0)
    expect(await testContract.balanceOf(otherThem.address)).to.equal(10)
  })
})
