# Collection NFT Contract

## Deploy

1. Pull repo locally and copy `.env.sample` into another file called `.env`. Fill out the fields in this file with your ethereum client's url and your public and private keys.
2. Run the following script

```bash
npm run deploy-dev
```

Done! The address of your deployed contract will be printed in the console on a successful deploy.

## Minting a Collection

1. For each NFT that you wish to be in the collection, use that NFT's `approve(to,tokenID)` or `setApprovalForAll(to)` with `to` being the address for the **Collection NFT** contract and `tokenID` being any tokenID you wish to Collectionize.
2. Once the **Collection NFT** contract has all of the NFTs you wish to mint into a Collection, call **Collection NFT**'s `mint(contractAddresses,tokenIDs)` function where `tokenIDs` is a array of all of the token IDs to be in the collection and `contractAddresses` is an equal length array of the contract addresses for each token ID where the indicies of each array corresponds to the contract to token relationship of every token. (e.g. `mint([0x9a..0d, 0x19..pz], [0,1])` will mint a collection with the NFT at contract address 0x9a..0d and token ID 0 and the NFT at contract address 0x19..pz with token ID 1)

_Note: if you accidentally send an NFT to the **Collection NFT** contract you can call the `pullNFT(contractAddress,tokenID)` function that will send your NFT back to you. Once a collection has been minted, however, this function is no longer available._

_Note: a Collection NFT may represent no more than 10 NFTs._

## Unwrapping a Collection into individual NFTs

1. Use **Collection NFT**'s `burn(tokenID)` function (which can only be called by the owner of a token) and all of the NFTs in a Collection will be sent to the owner of the Collection NFT. The Collection NFT will be burnt as well.

## TokenURI

The token URI for this contract (received by calling `tokenURI(tokenID)`) will be a base64 encoded JSON document that describes the collection and provides an SVG image depicting the list of NFTs that make up the collection.

If you wish to get a list of the NFTs in a Collection with their contract addresses and token IDs, call `getNFTsForCollection(collectionID)` and a list of NFTs with contract addresses and token IDs will be returned.

## ERC-721 Functionality

This contract implements the ERC-721 specification allowing Collections to be owned and sent in the ways that any other ERC-721 compliant token can be.
