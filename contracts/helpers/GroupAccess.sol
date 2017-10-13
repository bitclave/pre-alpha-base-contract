pragma solidity ^0.4.11;


contract GroupAccess {
    address[] public group;

    function GroupAccess(address[2] _group) {
        group = _group;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier groupAccess() {
        bool access = false;
        for (uint i = 0; i < group.length; i++) {
            if (msg.sender == group[i]) {
                access = true;
            }
        }

        require(access);

        _;
    }

    function changeGroupAccess(address[] newGroup) groupAccess public {
        require(newGroup.length > 0);
        group = newGroup;
    }

}



