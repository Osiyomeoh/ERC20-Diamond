// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../contracts/Diamond.sol";
import "../contracts/facets/DiamondCutFacet.sol";
import "../contracts/facets/DiamondLoupeFacet.sol";
import "../contracts/facets/ERC721Facet.sol";
import "../contracts/facets/MerkleFacet.sol";
import "../contracts/facets/PresaleFacet.sol";
import "../contracts/interfaces/IDiamondCut.sol";

contract DiamondTest is Test {
    Diamond public diamond;
    DiamondCutFacet public diamondCutFacet;
    DiamondLoupeFacet public diamondLoupeFacet;
    ERC721Facet public erc721Facet;
    MerkleFacet public merkleFacet;
    PresaleFacet public presaleFacet;

    function setUp() public {
        // Deploy facets
        diamondCutFacet = new DiamondCutFacet();
        diamondLoupeFacet = new DiamondLoupeFacet();
        erc721Facet = new ERC721Facet();
        merkleFacet = new MerkleFacet();
        presaleFacet = new PresaleFacet();

        // Deploy Diamond
        diamond = new Diamond(address(this), address(diamondCutFacet));

        // Add facets
        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](4);

        cut[0] = IDiamondCut.FacetCut({
            facetAddress: address(diamondLoupeFacet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: generateSelectors("DiamondLoupeFacet")
        });

        cut[1] = IDiamondCut.FacetCut({
            facetAddress: address(erc721Facet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: generateSelectors("ERC721Facet")
        });

        cut[2] = IDiamondCut.FacetCut({
            facetAddress: address(merkleFacet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: generateSelectors("MerkleFacet")
        });

        cut[3] = IDiamondCut.FacetCut({
            facetAddress: address(presaleFacet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: generateSelectors("PresaleFacet")
        });

        IDiamondCut(address(diamond)).diamondCut(cut, address(0), "");
    }

    function testMint() public {
        ERC721Facet(address(diamond)).mint(address(this));
        assertEq(ERC721Facet(address(diamond)).balanceOf(address(this)), 1);
    }

    function testPresale() public {
        PresaleFacet(address(diamond)).startPresale();
        uint256 initialBalance = address(this).balance;
        PresaleFacet(address(diamond)).buyTokens{value: 0.1 ether}();
        assertEq(ERC721Facet(address(diamond)).balanceOf(address(this)), 3);
        assertEq(address(this).balance, initialBalance - 0.1 ether);
    }

    function testMerkleDistribution() public {
        // This part would typically use a merkle tree generated off-chain
        // For simplicity, we'll just set a dummy root and proof
        bytes32 dummyRoot = keccak256("dummy_root");
        MerkleFacet(address(diamond)).setMerkleRoot(dummyRoot);

        bytes32[] memory dummyProof = new bytes32[](1);
        dummyProof[0] = keccak256("dummy_proof");

        // This will fail because we're using dummy data
        vm.expectRevert("Invalid merkle proof");
        MerkleFacet(address(diamond)).claim(dummyProof);
    }

    // Helper function to generate function selectors
    function generateSelectors(string memory _facetName)
        internal
        returns (bytes4[] memory selectors)
    {
        string[] memory cmd = new string[](3);
        cmd[0] = "node";
        cmd[1] = "scripts/genSelectors.js";
        cmd[2] = _facetName;
        bytes memory res = vm.ffi(cmd);
        selectors = abi.decode(res, (bytes4[]));
    }
}