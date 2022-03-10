// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.1;

import "hardhat/console.sol";

// importing openzeppelin contracts
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import { Base64 } from "./libraries/Base64.sol";

// inheriting the imported contracts to access
// methods of inherited contracts
contract MyEpicNFT is ERC721URIStorage {
    // For keeping track of tokenIds
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // setting minting limit
    uint MAX_SUPPLY = 100;

    // base SVG code that would be updated later with 
    // random strings from arrays
    string baseSvg = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='black' /><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";


    // arrrays for random words
    string[] firstWords = ["Epic", "Lazy", "Honest", "Aggressive", "Brainy", "Bored", "Cheerful", "Crazy", "Dizzy", "Envious", "Gentle", "Fantastic", "Legendary", "Glorious", "Jittery", "Nasty"];
    string[] secondWords = ["Monkey", "Panda", "Tiger", "Snake", "Falcon", "Mantis", "Rat", "Turtle", "Bull", "Elephant", "Girrafe", "Zebra", "Lion", "Hawk", "Hippo", "Croc"];
    string[] thirdWords = ["Noodles", "Biryani", "Pasta", "Falafel", "Idli", "Pizza", "Burger", "Sandwich", "Thepla", "Fafda", "Kulche", "Momos", "Nuggets", "Lasagna", "Frankie", "Tacco"];
    
    // event for minted nfts
    event NewEpicNFTMinted(address sender, uint256 tokenId);

    // random seed 
    uint seed;

    // Naming and symboling out nft
    constructor() ERC721("Dennys", "DNY") {
        console.log("this is my NFT contract. Woah..!!");
        seed = ((block.timestamp + block.difficulty) % 100);
    }

    // function for random picking
    function pickRandomFirstWord(uint256 tokenId) public view returns(string memory){
        // seeding random generator
        uint256 rand = random(string(abi.encodePacked("FIRST_WORD", Strings.toString(tokenId))));

        // squashing the number from 0 to array length
        rand = rand % firstWords.length;

        return firstWords[rand];
    }

    function pickRandomSecondWord(uint256 tokenId) public view returns(string memory){
        // seeding random generator
        uint256 rand = random(string(abi.encodePacked("SECOND_WORD", Strings.toString(tokenId))));

        // squashing the number from 0 to array length
        rand = rand % secondWords.length;

        return secondWords[rand];
    }
    
    function pickRandomThirdWord(uint256 tokenId) public view returns(string memory){
        // seeding random generator
        uint256 rand = random(string(abi.encodePacked("THIRD_WORD", Strings.toString(tokenId))));

        // squashing the number from 0 to array length
        rand = rand % thirdWords.length;

        return thirdWords[rand];
    }

    function random(string memory input) internal pure returns(uint256){
        return uint256(keccak256(abi.encodePacked(input)));
    }

    function seeder() internal returns(uint) {
        seed = ((block.timestamp + block.difficulty + seed) % 100);
        return seed;
    }

    uint public inSupply;

    function getInSupply() public view returns(uint){
        return inSupply;
    }

    // user accesible func to mint NFT
    function makeAnEpicNFT() public {
        require(inSupply < MAX_SUPPLY, "All tokens minted!");

        // get the current tokenId (starts with 0)
        uint256 newItemId = _tokenIds.current();

        uint256 seeding = seeder() + newItemId;

        // randomly grabing one word from each array
        string memory first = pickRandomFirstWord(seeding);
        string memory second = pickRandomSecondWord(seeding);
        string memory third = pickRandomThirdWord(seeding);
        string memory combinedWord = string(abi.encodePacked(first,second,third));

        // concatenating complete SVG string
        string memory finalSvg = string(abi.encodePacked(baseSvg, combinedWord, "</text></svg>"));
        

        // setting up the metadata
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "', combinedWord,
                            '", "description": "A great collection of funny words.", ',
                            '"image": "data:image/svg+xml;base64,', 
                            Base64.encode(bytes(finalSvg)), '"}'
                        )
                    )
                )
            );

        // setting Token URI
        string memory finalTokenUri = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        console.log("\n--------------------");
        console.log(string(
        abi.encodePacked(
            "https://nftpreview.0xdev.codes/?code=",
            finalTokenUri
        )
    ));
        console.log("--------------------\n");

        // actually minting NFT to caller
        _safeMint(msg.sender, newItemId);

        // Setting NFTs data
        _setTokenURI(newItemId, finalTokenUri);
        console.log("An NFT w/ ID %s has been minted to %s", newItemId, msg.sender);

        emit NewEpicNFTMinted(msg.sender, newItemId);
        // emiting succesful mint event

        // incrementing tokenId for next mint
        _tokenIds.increment();

        inSupply = inSupply + 1;
        console.log("insupply: ", inSupply);
    }
}