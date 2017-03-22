pragma solidity ^0.4.7;

import "../controller/Controller.sol";

contract NonSelfUnregistration {

  Controller public controller;

    function check( address _scheme, bytes _param , Controller _controller) {
      controller = _controller;

      // *** check that a scheme hasn't unregistered itself ***

      // param_ is the name of the controller function that has called the constraints
      // and _scheme is the scheme that has called that function (msg.sender)

      // check if _param is "unregisterScheme" (and return True if it isn't)

      bytes memory unregisterSchemeString = "unregisterScheme";

      if( _param.length != unregisterSchemeString.length ) return true;
      for( uint i = 0 ; i < _param.length ; i++ ) {
          if( _param[i] != unregisterSchemeString[i] ) return true;
      }
      // if it is, check that the scheme that has called that function is still registered after the call
      if( ! controller.schemes(_scheme) ) return false;

    }

}
