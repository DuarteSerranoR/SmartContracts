pragma solidity ^0.8.0;

contract RockPaperScissors {
    struct Player {
        address payable addr;
        bytes32 commitments;
        uint choice;
        bool hasRevealed;
    }

    /*
    enum PlayType {
        ROCK: 0,
        PAPER: 1,
        SCISSORS: 2
    }
    */

    Player[2] public players;

    uint256 firstRevealTime;
    uint public numPlayers;
    uint public reward;
    uint[3][3] rules;

    constructor() {
        numPlayers = 0;
        reward = 0;
        firstRevealTime = 0;

        //rock == 0; paper == 1; scissors == 2
        //rock beats scissors; paper beats rock; scissors beats paper
        //c0 and c1 are choices of players 0 and 1, respectively
        //rules [c0][c1] = winning player (0 or 1) or tie (2)
        rules[0][0] = 2; rules[0][1] = 1; rules[0][2] = 0;
        rules[1][0] = 0; rules[1][1] = 2; rules[1][2] = 1;
        rules[2][0] = 1; rules[2][1] = 0; rules[2][2] = 2;
    }

    function playerInput(bytes32 commitment) public payable returns (bool) {
        if(numPlayers < 2 && msg.value >= 1000) {
            reward += 1000;
            players[numPlayers].addr = payable(msg.sender);
            players[numPlayers].commitments = commitment;
            players[numPlayers].hasRevealed = false;
            //players[numPlayers].choice = choice;
            numPlayers = numPlayers + 1;
            if (msg.value > 1000) { // return remaining
                payable(msg.sender).transfer(msg.value-1000);
            }

            return true;
        } else {
            payable(msg.sender).transfer(msg.value);
            return false;
        }
    }

    function RevealChoice(uint choice, uint nonce) public returns (bool) {
        if(numPlayers < 2)
            return false;

        uint p;
        if (msg.sender == players[0].addr) {
            p = 0;
        } else if (msg.sender == players[1].addr) {
            p = 1;
        } else {
            return false;
        }

        if(!players[p].hasRevealed && // not revealed yet
            sha256(abi.encodePacked(choice,nonce)) == players[p].commitments) {
                players[p].choice = choice;
                players[p].hasRevealed = true;

                if (firstRevealTime == 0) {
                    firstRevealTime = block.timestamp;
                }
                return true;
        } else {
            return false;
        }
    }

    function finalize() public returns (int32) {
        if(numPlayers == 2) {
            uint p0 = players[0].choice;
            uint p1 = players[1].choice;

            if(rules[p0][p1] == 0) {
                players[0].addr.transfer(reward);
                return 0;
            } else if(rules[p0][p1] == 1) {
                players[1].addr.transfer(reward);
                return 1;
            } else {
                players[0].addr.transfer(reward/2);
                players[1].addr.transfer(reward/2);
                return 2;
            }

        } else if((block.timestamp > firstRevealTime + 1 days) && (players[0].hasRevealed || players[1].hasRevealed)) {
            if(players[1].hasRevealed) {
                players[1].addr.transfer(reward);
                return 1;
            } else {
                players[0].addr.transfer(reward);
                return 0;
            }
        } else {
            return -1;
        }
    }

    /*----- Function to be removed (should be executed on the client side) -----*/
    function generateBind(uint choice, uint nonce) public pure returns (bytes32) {
        return sha256(abi.encodePacked(choice,nonce));
    }
}
