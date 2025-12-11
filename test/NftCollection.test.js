const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("NftCollection", function () {
    let nft;
    let owner, addr1;

    beforeEach(async function () {
        [owner, addr1] = await ethers.getSigners();

        const NFT = await ethers.getContractFactory("NftCollection");
        nft = await NFT.deploy("MyNFT", "MNFT", 100, "https://baseuri.com/");
        await nft.waitForDeployment();
    });

    it("Should initialize correctly", async function () {
        expect(await nft.name()).to.equal("MyNFT");
        expect(await nft.symbol()).to.equal("MNFT");
        expect(await nft.maxSupply()).to.equal(100);
        expect(await nft.totalSupply()).to.equal(0);
    });

    it("Owner should mint successfully", async function () {
        await nft.safeMint(owner.address, 1);
        expect(await nft.ownerOf(1)).to.equal(owner.address);
    });

    it("Should revert if non-owner tries to mint", async function () {
        await expect(
            nft.connect(addr1).safeMint(addr1.address, 1)
        ).to.be.revertedWith("Not authorized");
    });

    it("Should transfer token", async function () {
        await nft.safeMint(owner.address, 1);
        await nft.transferFrom(owner.address, addr1.address, 1);

        expect(await nft.ownerOf(1)).to.equal(addr1.address);
    });
});
