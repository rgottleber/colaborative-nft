// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "ds-test/test.sol";
import "../Contract.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

contract ContractTest is DSTest, ERC721Holder {
    TLNFT public c;

    function setUp() public {
        c = new TLNFT(123);
    }

    function testExample() public {
        c.callRandomWords(1, 2);
        c.callRandomWords(378946589072365980723645, 78623456782345678234567);
        c.callRandomWords(7877893465097813645, 786345890672347896);
        c.callRandomWords(34897560923846, 234567568946);
        c.callRandomWords(2394785023894750982374509823745, 8567723456);
        c.callRandomWords(234985762937846598723645789, 1346438);
        c.callRandomWords(3456787654, 678595678956784567856);
        c.callRandomWords(876845676345, 8456785678945686479856789);
        c.callRandomWords(67823456782345678234, 7569567956798567956);
        c.callRandomWords(
            667890345789053478934578834579578349345789,
            567894673456734567
        );
        emit log(c.getSVG());
        emit log(c.tokenURI(0));
    }

    function testClaim() public {
        c.callRandomWords(123123, 123123123123);
    }
}
