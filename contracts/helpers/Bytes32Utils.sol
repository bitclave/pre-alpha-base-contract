pragma solidity ^0.4.11;


library Bytes32Utils {

    function toString(bytes32 value) internal constant returns (string) {
        bytes memory bytesString = new bytes(32);
        uint charCount = 0;
        byte char;

        for (uint j = 0; j < 32; j++) {
            char = byte(bytes32(uint(value) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (j = 0; j < charCount; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }
        return string(bytesStringTrimmed);
    }

    function toUInt(bytes32 value) internal constant returns (uint ret) {
        if (value == 0x0) {
            return 0;
        }

        uint digit;

        for (uint i = 0; i < 32; i++) {
            digit = uint((uint(value) / (2 ** (8 * (31 - i)))) & 0xff);
            if (digit == 0) {
                break;
            }
            else if (digit < 48 || digit > 57) {
                return 0;
            }
            ret *= 10;
            ret += (digit - 48);
        }
        return ret;
    }

}
