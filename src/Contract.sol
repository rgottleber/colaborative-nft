// SPDX-License-Identifier: MIT
// An example of a consumer contract that relies on a subscription for funding.
pragma solidity ^0.8.10;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract ClaimYourSpot is VRFConsumerBaseV2, ERC721, ERC721URIStorage {
    VRFCoordinatorV2Interface COORDINATOR;

    // Your subscription ID.
    uint64 s_subscriptionId;

    // Rinkeby coordinator. For other networks,
    // see https://docs.chain.link/docs/vrf-contracts/#configurations
    address vrfCoordinator = 0x2eD832Ba664535e5886b75D64C46EB9a228C2610;

    // The gas lane to use, which specifies the maximum gas price to bump to.
    // For a list of available gas lanes on each network,
    // see https://docs.chain.link/docs/vrf-contracts/#configurations
    bytes32 keyHash =
        0x354d2f95da55398f44b7cff77da56283d9c6c829a4bdf1bbcaf2ad6a4d081f61;

    // Depends on the number of requested values that you want sent to the
    // fulfillRandomWords() function. Storing each word costs about 20,000 gas,
    // so 100,000 is a safe default for this example contract. Test and adjust
    // this limit based on the network that you select, the size of the request,
    // and the processing of the callback request in the fulfillRandomWords()
    // function.
    uint32 callbackGasLimit = 999999;

    // The default is 3, but you can set this higher.
    uint16 requestConfirmations = 1;

    // For this example, retrieve 2 random values in one request.
    // Cannot exceed VRFCoordinatorV2.MAX_NUM_WORDS.
    uint32 numWords = 1;

    uint256[] public s_randomWords;
    uint256 s_requestId;
    address s_owner;
    mapping(uint256 => address) public requestIdToAddress;
    uint256 public width = 1920;
    uint256 public height = 1080;
    string finalSVG;
    string headSVG =
        string(
            abi.encodePacked(
                "<svg viewBox='0 0 ",
                Strings.toString(width),
                " ",
                Strings.toString(height),
                "' preserveAspectRatio='xMidYMid meet'>",
                "<rect width='",
                Strings.toString(width),
                "' height='",
                Strings.toString(height),
                "' fill='#1A1B27' />"
            )
        );
    string tailSVG = "</svg>";
    string bodySVG = "";
    string lastCircle = "";
    string[] colors = ["#3F5ACB", "#EA5D65", "#F0CD49", "#FFFFFF"];

    struct CircleAttributes {
        string x;
        string y;
        string r;
        string fill;
    }

    CircleAttributes[] circles;

    event SpotClaimed(string notification);

    constructor(uint64 subscriptionId)
        VRFConsumerBaseV2(vrfCoordinator)
        ERC721("SmartCon22 Spots", "SCS")
    {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        s_owner = msg.sender;
        s_subscriptionId = subscriptionId;
        _safeMint(s_owner, 0);
    }

    // Assumes the subscription is funded sufficiently.
    function claimYourSpot() public {
        // Will revert if subscription is not set and funded.
        s_requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
    }

    function getSVG() public view returns (string memory SVG) {
        return finalSVG;
    }

    function fulfillRandomWords(uint256, uint256[] memory randomWords)
        internal
        override
    {
        s_randomWords = randomWords;
        addNewCircle(randomWords[0]);
        emit SpotClaimed("New Spot Claimed");
    }

    function addNewCircle(uint256 randomNumber) internal {
        // if there is a circle already, redo the last one to remove the class

        circles.push(
            CircleAttributes({
                x: string(Strings.toString(randomNumber % width)),
                y: string(Strings.toString(randomNumber % height)),
                r: string(Strings.toString((randomNumber % 8) + 2)),
                fill: colors[randomNumber % 4]
            })
        );
        if (circles.length > 1) {
            bodySVG = string(
                abi.encodePacked(
                    bodySVG,
                    "<circle cx='",
                    circles[circles.length - 2].x,
                    "' cy='",
                    circles[circles.length - 2].y,
                    "' r='",
                    circles[circles.length - 2].r,
                    "' fill='",
                    circles[circles.length - 2].fill,
                    "' />"
                )
            );
        }
        lastCircle = string(
            abi.encodePacked(
                "<circle cx='",
                circles[circles.length - 1].x,
                "' cy='",
                circles[circles.length - 1].y,
                "' class='pulse'",
                " r='",
                circles[circles.length - 1].r,
                "' fill='",
                circles[circles.length - 1].fill,
                "' />"
            )
        );
        string memory _finalSVG = string(
            abi.encodePacked(headSVG, bodySVG, lastCircle, tailSVG)
        );
        finalSVG = _finalSVG;
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "Colab NFT",',
                        '"description": "All the spots, randomly picked, by YOU!",',
                        '"image": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(_finalSVG)),
                        '"}'
                    )
                )
            )
        );
        string memory finalTokenURI = string(
            abi.encodePacked("data:application/json;base64,", json)
        );
        _setTokenURI(0, finalTokenURI);
    }

    modifier onlyOwner() {
        require(msg.sender == s_owner);
        _;
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
}
