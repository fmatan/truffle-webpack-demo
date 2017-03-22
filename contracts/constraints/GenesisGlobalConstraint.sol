pragma solidity ^0.4.7;

import '../controller/Controller.sol';
import '../controller/MintableToken.sol';
import "../helpers/SimpleVoteInterface.sol";
import "./GlobalConstraintInterface.sol";
import "./NonSelfUnregistration.sol";

contract GenesisGlobalConstraint is GlobalConstraintInterface {
    Controller public controller;
    MintableToken public mintableToken;
    NonSelfUnregistration public nonSelfUnregistration;

    function GenesisGlobalConstraint ( NonSelfUnregistration _nonSelfUnregistration ){
      nonSelfUnregistration = _nonSelfUnregistration;
    }

    function setController( Controller _controller ) returns(bool) {
        controller = _controller;
        mintableToken = controller.nativeToken();
    }

    function pre( address _scheme, bytes _param ) returns(bool) { return true; }

    function post( address _scheme, bytes _param ) returns(bool) {

        // *** check that a scheme hasn't unregistered itself ***
        if ( ! nonSelfUnregistration.check(_scheme, _param, controller) ) return false;


        // *** cap the total supply of tokens at 10M (with token resolution of 10^18 units) ***
        if (mintableToken.totalSupply() > 10**(8+18) ) return false;
        return true;

        return true;
    }
}

/*

DAOstack constraints:

1. cap of 10M tokens
2. token sale scheme (TBD) is unique
3. limit burn rate of tokens to contributors

*/
