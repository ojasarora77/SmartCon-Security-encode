// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../src/MutationGenerator.sol";

contract MutationGeneratorTest is Test {
    MutationGenerator generator;

    function setUp() public {
        generator = new MutationGenerator();
    }

    function testBasicMutation() public {
        string memory sourceCode = string(
            abi.encodePacked(
                "function test() public {\n",
                "    require(x >= y);\n",
                "}"
            )
        );

        generator.generateMutations(sourceCode);

        uint256 count = generator.getMutationsCount();
        assertGt(count, 0, "Should generate at least one mutation");

        (
            string memory originalLine,
            string memory mutatedLine,
            uint256 lineNumber,
            MutationGenerator.MutationType mutationType
        ) = generator.getMutation(0);

        console2.log("Original line:", originalLine);
        console2.log("Mutated line:", mutatedLine);
        console2.log("Line number:", lineNumber);

        assertTrue(
            contains(originalLine, ">=") && contains(mutatedLine, ">"),
            "Should mutate >= to >"
        );
        assertEq(
            uint256(mutationType),
            uint256(MutationGenerator.MutationType.Conditional),
            "Should be conditional mutation"
        );
    }

    // Changed to test logical operator mutation instead of arithmetic
    function testLogicalMutation() public {
        string memory sourceCode = string(
            abi.encodePacked(
                "function vote() public {\n",
                "    require(isActive && !hasVoted);\n",
                "}"
            )
        );

        generator.generateMutations(sourceCode);

        uint256 count = generator.getMutationsCount();
        assertGt(count, 0, "Should generate at least one mutation");

        (
            string memory originalLine,
            string memory mutatedLine,
            uint256 lineNumber,
            MutationGenerator.MutationType mutationType
        ) = generator.getMutation(0);

        console2.log("Original line:", originalLine);
        console2.log("Mutated line:", mutatedLine);
        console2.log("Line number:", lineNumber);

        assertTrue(
            contains(originalLine, "&&") && contains(mutatedLine, "||"),
            "Should mutate && to ||"
        );
        assertEq(
            uint256(mutationType),
            uint256(MutationGenerator.MutationType.Logical),
            "Should be logical mutation"
        );
    }

    function testMultiplicationMutation() public {
        string memory sourceCode = string(
            abi.encodePacked(
                "function calculateReward() public {\n",
                "    uint256 reward = baseAmount * multiplier;\n",
                "}"
            )
        );

        generator.generateMutations(sourceCode);

        uint256 count = generator.getMutationsCount();
        assertGt(count, 0, "Should generate at least one mutation");

        (
            string memory originalLine,
            string memory mutatedLine,
            uint256 lineNumber,
            MutationGenerator.MutationType mutationType
        ) = generator.getMutation(0);

        console2.log("Original line:", originalLine);
        console2.log("Mutated line:", mutatedLine);
        console2.log("Line number:", lineNumber);

        assertTrue(
            contains(originalLine, "*") && contains(mutatedLine, "/"),
            "Should mutate * to /"
        );
        assertEq(
            uint256(mutationType),
            uint256(MutationGenerator.MutationType.Arithmetic),
            "Should be arithmetic mutation"
        );
    }

    // Helper function to check string contains
    function contains(
        string memory source,
        string memory search
    ) internal pure returns (bool) {
        bytes memory sourceBytes = bytes(source);
        bytes memory searchBytes = bytes(search);

        if (searchBytes.length > sourceBytes.length) return false;

        for (uint i = 0; i < sourceBytes.length - searchBytes.length + 1; i++) {
            bool found = true;
            for (uint j = 0; j < searchBytes.length; j++) {
                if (sourceBytes[i + j] != searchBytes[j]) {
                    found = false;
                    break;
                }
            }
            if (found) return true;
        }
        return false;
    }
}
