pragma solidity ^0.4.8;

import "zeppelin-solidity/contracts/math/SafeMath.sol";
import 'zeppelin-solidity/contracts/token/BasicToken.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';

/*
* This contract using only for test.
*/
contract CAToken is BasicToken, Ownable {

    uint256 public constant decimals = 18;
    uint256 public constant totalSupply = 2000 * (10**6) * 10** decimals; // 2 billion tokens total limit

    /* Public variables of the token */
    string public standard = 'Token 0.1';
    string public name = 'CAT';
    string public symbol = 'CAT';

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function CAToken() {
        balances[msg.sender] = totalSupply;              // Give the creator all initial tokens
    }

}
