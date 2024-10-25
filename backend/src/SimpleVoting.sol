// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract SimpleVoting {
    address public admin;
    uint256 public minimumVotes;
    uint256 public proposalCount;
    mapping(uint256 => Proposal) public proposals;
    mapping(address => bool) public hasVoted;

    struct Proposal {
        string description;
        uint256 voteCount;
        bool executed;
        uint256 minVotesRequired;
    }

    event ProposalCreated(uint256 indexed proposalId, string description);
    event Voted(uint256 indexed proposalId, address voter);
    event ProposalExecuted(uint256 indexed proposalId);

    constructor(uint256 _minimumVotes) {
        require(_minimumVotes > 0, "Minimum votes must be > 0");
        admin = msg.sender;
        minimumVotes = _minimumVotes;
    }

    function createProposal(
        string memory _description,
        uint256 _minVotes
    ) public {
        require(msg.sender == admin, "Only admin can create proposals");
        require(_minVotes >= minimumVotes, "Below minimum vote threshold");

        proposalCount += 1;
        proposals[proposalCount] = Proposal({
            description: _description,
            voteCount: 0,
            executed: false,
            minVotesRequired: _minVotes
        });

        emit ProposalCreated(proposalCount, _description);
    }

    function vote(uint256 _proposalId) public {
        require(
            _proposalId > 0 && _proposalId <= proposalCount,
            "Invalid proposal"
        );
        require(!hasVoted[msg.sender], "Already voted");
        require(!proposals[_proposalId].executed, "Proposal already executed");

        proposals[_proposalId].voteCount += 1;
        hasVoted[msg.sender] = true;

        emit Voted(_proposalId, msg.sender);
    }

    function executeProposal(uint256 _proposalId) public {
        require(msg.sender == admin, "Only admin can execute");
        require(
            _proposalId > 0 && _proposalId <= proposalCount,
            "Invalid proposal"
        );
        require(!proposals[_proposalId].executed, "Already executed");
        require(
            proposals[_proposalId].voteCount >=
                proposals[_proposalId].minVotesRequired,
            "Not enough votes"
        );

        proposals[_proposalId].executed = true;
        emit ProposalExecuted(_proposalId);
    }

    function getProposal(
        uint256 _proposalId
    )
        public
        view
        returns (
            string memory description,
            uint256 voteCount,
            bool executed,
            uint256 minVotesRequired
        )
    {
        require(
            _proposalId > 0 && _proposalId <= proposalCount,
            "Invalid proposal"
        );
        Proposal memory proposal = proposals[_proposalId];
        return (
            proposal.description,
            proposal.voteCount,
            proposal.executed,
            proposal.minVotesRequired
        );
    }
}
