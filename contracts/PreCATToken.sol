pragma solidity ^0.4.8;

import "zeppelin-solidity/contracts/math/SafeMath.sol";


contract PreCATToken {
    using SafeMath for uint256;

    uint256 public constant decimals = 18;
    uint256 public constant totalSupply = 2000 * (10**6) * 10** decimals; // 2 billion tokens total limit

    /* This generates a public event on the blockchain that will notify clients */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /* Public variables of the token */
    string public standard = 'Token 0.1';
    string public name;
    string public symbol;

    /* This creates an array with all balances */
    mapping (address => uint256) public balances;

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function PreCATToken(
        string tokenName,
        string tokenSymbol
    ) {
        balances[msg.sender] = totalSupply;              // Give the creator all initial tokens
        name = tokenName;                                   // Set the name for display purposes
        symbol = tokenSymbol;                               // Set the symbol for display purposes
    }

    /* Send coins */
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));

        // SafeMath.sub will throw if there is not enough balance.
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);

        return true;
    }

    /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }

}
