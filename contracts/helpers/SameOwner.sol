pragma solidity ^0.4.0;

import 'zeppelin-solidity/contracts/ownership/Ownable.sol';


contract SameOwner is Ownable {

    function isContractAddress(address _address) internal constant returns(bool) {
        uint size;
        assembly {
            size := extcodesize(_address)
        }
        return size > 0;
    }

    modifier onlySameOwner() {
        if (isContractAddress(msg.sender)) {
            require(Ownable(msg.sender).owner() == owner);

        } else {
            require(msg.sender == owner);
        }

        _;
    }

}
