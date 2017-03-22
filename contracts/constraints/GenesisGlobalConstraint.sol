pragma solidity ^0.4.7;

import '../controller/Controller.sol';
import '../controller/MintableToken.sol';
import "../helpers/SimpleVoteInterface.sol";
import "./GlobalConstraintInterface.sol";

contract GenesisGlobalConstraint is GlobalConstraintInterface {
    Controller public controller;
    MintableToken public mintableToken;


    function setController( Controller _controller ) returns(bool) {
        controller = _controller;
        mintableToken = controller.nativeToken();
    }

    function pre( address _scheme, bytes _param ) returns(bool) { return true; }
    function post( address _scheme, bytes _param ) returns(bool) {
        bytes memory unregisterSchemeString = "unregisterScheme";

        // *** check that a scheme hasn't unregistered itself ***

        // param_ is the name of the controller function that has called the constraints
        // and _scheme is the scheme that has called that function (msg.sender)

        // check if _param is "unregisterScheme" (and return True if it isn't)
        if( _param.length != unregisterSchemeString.length ) return true;
        for( uint i = 0 ; i < _param.length ; i++ ) {
            if( _param[i] != unregisterSchemeString[i] ) return true;
        }

        // if it is, check that the scheme that has called that function is still registered after the call
        if( ! controller.schemes(_scheme) ) return false;

        // *** cap the total supply of tokens at 10M (with token resolution of 10^18 units) ***
        if (mintableToken.totalSupply() > 10**(8+18) ) return false;
        return true;




        return true;
    }
}
