// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/SimpleVoting.sol";

contract SimpleVotingTest is Test {
    SimpleVoting voting;
    address admin = address(this);
    address voter1 = address(0x1);
    address voter2 = address(0x2);

    function setUp() public {
        voting = new SimpleVoting(2); // Minimum 2 votes required
    }

    function testCreateProposal() public {
        voting.createProposal("Test Proposal", 2);
        (string memory description, , , uint256 minVotes) = voting.getProposal(
            1
        );
        assertEq(description, "Test Proposal");
        assertEq(minVotes, 2);
    }

    function testFailCreateProposalUnauthorized() public {
        vm.prank(voter1);
        voting.createProposal("Test Proposal", 2);
    }

    function testFailCreateProposalBelowMinimum() public {
        voting.createProposal("Test Proposal", 1);
    }

    function testVoting() public {
        voting.createProposal("Test Proposal", 2);

        vm.prank(voter1);
        voting.vote(1);

        (, uint256 voteCount, , ) = voting.getProposal(1);
        assertEq(voteCount, 1);
        assertTrue(voting.hasVoted(voter1));
    }

    function testFailDoubleVote() public {
        voting.createProposal("Test Proposal", 2);

        vm.prank(voter1);
        voting.vote(1);

        vm.prank(voter1);
        voting.vote(1);
    }

    function testExecuteProposal() public {
        voting.createProposal("Test Proposal", 2);

        vm.prank(voter1);
        voting.vote(1);

        vm.prank(voter2);
        voting.vote(1);

        voting.executeProposal(1);

        (, , bool executed, ) = voting.getProposal(1);
        assertTrue(executed);
    }

    function testFailExecuteWithoutEnoughVotes() public {
        voting.createProposal("Test Proposal", 2);

        vm.prank(voter1);
        voting.vote(1);

        voting.executeProposal(1);
    }

    function testFailExecuteUnauthorized() public {
        voting.createProposal("Test Proposal", 2);

        vm.prank(voter1);
        voting.vote(1);

        vm.prank(voter2);
        voting.vote(1);

        vm.prank(voter1);
        voting.executeProposal(1);
    }
}
