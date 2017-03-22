pragma solidity ^0.4.7;
import '../controller/Controller.sol';
import "../helpers/SimpleVoteInterface.sol";
import "../constraints/GenesisGlobalConstraint.sol";


contract GenesisScheme {
    Controller public controller;
    SimpleVoteInterface public simpleVote;

    struct Founder {
        int128 tokens;
        int128 reputation;
    }

    mapping(address=>Founder) founders;

    //event CollectFoundersShare( address indexed _founder, int _reputation, int _tokens );
    //event Vote( address _voter, bool _yes, address _scheme );

    function GenesisScheme( string tokenName,
                            string tokenSymbol,
                            address[] _founders,
                            int128[] _tokenAmount,
                            int128[] _reputationAmount,
                            SimpleVoteInterface _simpleVote ) {

        NonSelfUnregistration nonSelfUnregistration = new NonSelfUnregistration();
        GenesisGlobalConstraint globalContraints = new GenesisGlobalConstraint(nonSelfUnregistration);
        controller = new Controller( tokenName, tokenSymbol, this, globalContraints );
        globalContraints.setController(controller);
        simpleVote = _simpleVote;
        simpleVote.setOwner(this);
        simpleVote.setReputationSystem(controller.nativeReputation());

        for( uint i = 0 ; i < _founders.length ; i++ ) {
            Founder memory founder;
            founder.tokens = _tokenAmount[i];
            founder.reputation = _reputationAmount[i];

            founders[_founders[i]] = founder;
        }
    }

    function collectFoundersShare( ) returns(bool) {

        Founder memory founder = founders[msg.sender];

        if( ! controller.mintTokens( int(founder.tokens), msg.sender ) ) throw;
        if( ! controller.mintReputation( int(founder.reputation), msg.sender ) ) throw;

        //CollectFoundersShare( msg.sender, int(founder.reputation), int(founder.tokens) );

        delete founders[msg.sender];

        return true;
    }


    function proposeScheme( address _scheme ) returns(bool) {
        return simpleVote.newProposal(sha3(_scheme));
    }

    function voteScheme( address _scheme, bool _yes ) returns(bool) {
        //Vote( msg.sender, _yes, _scheme );

        if( ! simpleVote.voteProposal(sha3(_scheme),_yes, msg.sender) ) return false;
        if( simpleVote.voteResults(sha3(_scheme)) ) {
            if( ! simpleVote.closeProposal(sha3(_scheme) ) ) throw;
            if( controller.schemes(_scheme) ) {
                if( ! controller.unregisterScheme(_scheme) ) throw;
            }
            else {
                if( ! controller.registerScheme(_scheme) ) throw;
            }
        }

    }

    function getVoteStatus(address _scheme) constant returns(uint[4]) {
        return simpleVote.voteStatus(sha3(_scheme));
    }
}
