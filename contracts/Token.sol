// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.16 <0.9.0;

contract MyToken {
    address payable public minter;
    mapping (address => uint) public balances;
    uint rate;
    

    event Sent(address from, address to, uint amount);

    constructor() {
        minter = payable(msg.sender);
        rate = 10**18;
    }

    function mint(address receiver, uint amount) public {
        if(msg.sender != minter) return;
        balances[receiver] += amount;
    }

    function sender(address receiver, uint amount) public {
        if(balances[msg.sender] < amount) return;
        balances[msg.sender] -= amount;
        balances[receiver] += amount;

        emit Sent(msg.sender, receiver, amount);
    }

    function setConversionRate(uint newRate) public {
        if(msg.sender != minter) return;
        rate = newRate;
    }

    function buyToken() public payable {
        if(rate == 0) {
            payable(msg.sender).transfer(msg.value);
        } else {
            minter.transfer(msg.value);
            balances[msg.sender] += msg.value / rate;
        }
    }
}