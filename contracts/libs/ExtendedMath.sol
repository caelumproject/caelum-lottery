//solium-disable linebreak-style
pragma solidity 0.4.24;

library ExtendedMath {
    function limitLessThan(uint a, uint b) internal pure returns(uint c) {
        if (a > b) return b;
        return a;
    }
}
