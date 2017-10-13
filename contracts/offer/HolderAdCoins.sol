pragma solidity ^0.4.11;

import "../PreCATToken.sol";
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';


contract HolderAdCoins is Ownable {

    PreCATToken private tokenContract;
    address advertiser;

    function HolderAdCoins(address _tokenContract, address _advertiser) {
        setTokensContract(_tokenContract);
        advertiser = _advertiser;
    }

    function setTokensContract(address contractAddress) onlyOwner public {
        tokenContract = PreCATToken(contractAddress);
    }

    function transfer(address to, uint256 value) onlyOwner public returns (bool) {
        tokenContract.transfer(to, value);
        //fix me. need return result from PreCatToken. but uploaded contract not have result of operations.
        // apply this when will be uploaded new contract with fix.
        return true;
    }

    function refund(uint256 value) public {
        require(msg.sender == advertiser);

        tokenContract.transfer(advertiser, value);
    }

    function getBalance() public constant returns(uint256){
        return tokenContract.balanceOf(address(this));
    }

}
