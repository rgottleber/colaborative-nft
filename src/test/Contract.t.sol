// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "ds-test/test.sol";
import "../Contract.sol";
import "./mocks/MockVRFCoordinatorV2.sol";
import "./mocks/LinkToken.sol";
import "./utils/Cheats.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

contract ContractTest is DSTest, ERC721Holder {
    TLCNFT public c;
    LinkToken public linkToken;
    MockVRFCoordinatorV2 public vrfCoordinator;
    Cheats internal constant cheats = Cheats(HEVM_ADDRESS);

    uint96 constant FUND_AMOUNT = 1 * 10**18;
    // Initialized as blank, fine for testing
    uint64 subId;
    bytes32 keyHash; // gasLane

    event ReturnedRandomness(uint256[] randomWords);

    function setUp() public {
        linkToken = new LinkToken();
        vrfCoordinator = new MockVRFCoordinatorV2();
        subId = vrfCoordinator.createSubscription();
        vrfCoordinator.fundSubscription(subId, FUND_AMOUNT);
        c = new TLCNFT(
            subId,
            address(vrfCoordinator),
            address(linkToken),
            keyHash
        );
        vrfCoordinator.addConsumer(subId, address(c));
        c.mintNFT(address(this));
    }

    function testExample() public {
        c.claimYourSpot();
        c.claimYourSpot();
        c.claimYourSpot();
        emit log(c.tokenURI(0));
    }

    function testClaim() public {
        c.claimYourSpot();
        c.tokenURI(0);
    }

    function testSetup() public {}

    function testGetSVG() public view {
        c.tokenURI(0);
    }
}
