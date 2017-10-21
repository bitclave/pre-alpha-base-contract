pragma solidity ^0.4.8;

import "zeppelin-solidity/contracts/math/SafeMath.sol";
import 'zeppelin-solidity/contracts/token/BasicToken.sol';

/*
* This contract using only for test.
*/
contract PreCATToken is BasicToken {

    uint256 public constant decimals = 18;
    uint256 public constant totalSupply = 2000 * (10**6) * 10** decimals; // 2 billion tokens total limit

    /* Public variables of the token */
    string public standard = 'Token 0.1';
    string public name;
    string public symbol;

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function PreCATToken(
        string tokenName,
        string tokenSymbol
    ) {
        balances[msg.sender] = totalSupply;              // Give the creator all initial tokens
        name = tokenName;                                   // Set the name for display purposes
        symbol = tokenSymbol;                               // Set the symbol for display purposes
    }

}
