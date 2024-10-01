// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/// @title voting with delegation.

contract ballot{

    // this below represents a single voter
    struct voter{
        uint weight; // acumulated by delegation
        bool voted; // if true , then that person already voted
        address delegate; // person delegated to
        uint vote; // index of the voted proposal
    }

    // this below is a type for a single proposal
    struct proposal{
        bytes32 name; //short name upto 32 bytes
        uint votecount; //accumulated number of votes

    }

    address public chairperson;

    //this below declares a state variable that stores a voter's struct for each proposal
    mapping (address=>voter)public voters;

    //create a dynamically sized array of proposal structs
    proposal[]public proposals;

    // create a ballot to choose one of the proposal names
    function ballott(bytes32 [] memory proposalnames) public {
        chairperson=msg.sender;
        voters[chairperson].weight=1;

        // below, for each provided proposal names, create a new proposal object an add it to the end of the array

        for (uint i=0;i<proposalnames.length;i++){
            //proposal({}) creates a tempropary proposal object and proposal.push() appends it to the end of the proposals
            proposals.push(
                proposal({
                    name:proposalnames[i],
                    votecount:0

                })
            );
        }
    } 

    // below give the voter the right to vote on this ballot
    // may only be called by the chairperson

    function give_right_to_vote(address _voter) public view{
        // If the argument of `require` evaluates to `false`,
        // it terminates and reverts all changes to
        // the state and to Ether balances. It is often
        // a good idea to use this if functions are
        // called incorrectly. But watch out, this
        // will currently also consume all provided gas
        // (this is planned to change in the future).

        require((msg.sender==chairperson) && !voters[_voter].voted && (voters[_voter].weight==0));
        voters[_voter].weight==1;

    }

    // delegate your vote to voter `to`
    function delegate(address to) public view{
        //assigns reference 

        voter storage sender=voters[msg.sender];
        require (!sender.voted);

        //self delegation is not allowed.
        require (to != msg.sender);

        // Forward the delegation as long as
        // `to` also delegated.
        // In general, such loops are very dangerous,
        // because if they run too long, they might
        // need more gas than is available in a block.
        // In this case, the delegation will not be executed,
        // but in other situations, such loops might
        // cause a contract to get "stuck" completely.

        while (voters[to].delegate !=address (0)) {
            to=voters[to].delegate;

            //we found a loop in the delegation,not allowed
            require(to !=msg.sender);

            // Since `sender` is a reference, this
            // modifies `voters[msg.sender].voted`
            sender.voted=true;
            sender.delegate=to;

            voter storage delegate=voters[to];

            if (delegate.voted){
                // If the delegate already voted,
                // directly add to the number of votes

                proposal[delegate.vote].votecount +=sender.weight;
            } else {
                // If the delegate did not vote yet,
                // add to her weight.

                delegate.weight+=sender.weight;

            }
        }

        /// Give your vote (including votes delegated to you)
        /// to proposal `proposals[proposal].name`.
    function vote (uint proposal) public {
        Voter storage sender=voters[msg.sender];
        require(!sender.voted);
        sender.voted= true;
        sender.vote=proposal;
        // If `proposal` is out of the range of the array,
        // this will throw automatically and revert all
        // changes.
        proposals[proposal].votecount+=sender.weight;
    }
    /// @dev Computes the winning proposal taking all
    /// previous votes into account.
    function winningProposal() constant 
        returns (uint winningProposal)
    {
    uint winningvotecount=0;
    for (uint p=0; p<proposals.length; p++){
        if (proposals[p].votecount>winningvotecount) {
        winningvotecount=proposals[p].votecount;
        winningProposal=p;
            }
        }
    }
    // Calls winningProposal() function to get the index
    // of the winner contained in the proposals array and then
    // returns the name of the winner
    function winnerName() constant
        returns (bytes32 winnerName)
        { winnerName=proposals[winningProposal()].name;}
}
}
