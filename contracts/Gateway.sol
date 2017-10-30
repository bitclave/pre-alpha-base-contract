pragma solidity ^0.4.0;

import 'zeppelin-solidity/contracts/ownership/Ownable.sol';


contract Gateway is Ownable {

    address public baseContract;

    function Gateway(){

    }

    function setBaseContract(address _baseContractAddress) onlyOwner external {
        require(_baseContractAddress != address(0x0));

        baseContract = _baseContractAddress;
    }

}
