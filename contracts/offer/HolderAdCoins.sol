pragma solidity ^0.4.11;

import 'zeppelin-solidity/contracts/token/BasicToken.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';


contract HolderAdCoins is Ownable {

    BasicToken private tokenContract;
    address advertiser;

    function HolderAdCoins(address _tokenContract, address _advertiser) {
        setTokensContract(_tokenContract);
        advertiser = _advertiser;
    }

    function setTokensContract(address contractAddress) onlyOwner public {
        tokenContract = BasicToken(contractAddress);
    }

    function transfer(address to, uint256 value) onlyOwner public returns (bool) {
        return tokenContract.transfer(to, value);
    }

    function refund(uint256 value) public {
        require(msg.sender == advertiser);

        tokenContract.transfer(advertiser, value);
    }

    function getBalance() public constant returns(uint256){
        return tokenContract.balanceOf(address(this));
    }

}
