pragma solidity ^0.4.7;

contract GlobalConstraintInterface {
    function pre( address _scheme, bytes _param ) returns(bool);
    function post( address _scheme, bytes _param ) returns(bool);
}
