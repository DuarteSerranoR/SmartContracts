// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.16 <0.9.0;

contract SimpleStorage {
    uint storedData;

    function set(uint x) public {
        storedData = x;
    }

    function get() public view returns (uint) {
        return storedData;
    }

    function cas(uint x, uint y) public returns (uint) {
        if(x == storedData) {
            storedData = y;
            return x;
        }
        else return 0;
    }
}
