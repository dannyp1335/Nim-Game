pragma solidity >=0.6.2 <0.7.0;
// SPDX-License-Identifier: MIT

interface NimPlayer
{
    // Given a set of piles, return a pile number and a quantity of items to remove
    function nextMove(uint256[] calldata piles) external returns (uint, uint256);
    // Called if you win, with your winnings!
    function Uwon() external payable;
    // Called if you lost :-(
    function Ulost() external;
    // Called if you lost because you made an illegal move :-(
    function UlostBadMove() external;
}


interface Nim
{
    // fee is 0.001 ether, award the winner the rest
    function startMisere(NimPlayer a, NimPlayer b, uint256[] calldata piles) payable external;
}

contract NimBoard is Nim
{
    uint256[] boardGame;
    
    function startMisere(NimPlayer a, NimPlayer b, uint256[] calldata piles) payable external override
    {
        require(msg.value >= 0.001 ether);
        
        boardGame = piles;
        bool playerATurn = true;
        bool sticksLeft = true;
        
            
        while(sticksLeft)
        {
            uint pile;
            uint256 quantity;
            NimPlayer playerOne;
            NimPlayer playerTwo;
            
            if(playerATurn){
                currentOne = a;
                playerTwo  = b;
            }
            else{
                playerOne = b;
                playerTwo = a;
            }
            
            (pile,quantity) = playerOne.nextMove(boardGame);
            
         
            if(validPile(pile) && validQuantity(pile, quantity))
            {
                boardGame[pile] = boardGame[pile] - quantity;
            }
            else
            {
                playerOne.UlostBadMove();
                playerTwo.Uwon{value: msg.value - 0.001 ether}();
                return;
            }
                
            playerATurn = !playerATurn;
                
            
            bool sticks = false;
            uint256 stickCount = 0;
                
            for(uint i = 0; i < boardGame.length; i++)
            {
                if(boardGame[i] > 0)
                {
                    stickCount = stickCount + boardGame[i];
                    sticks = true;
                }
            }
            
            if(stickCount == 1)
            {
                if(playerATurn)
                {
                    a.Ulost();
                    b.Uwon{value: msg.value - 0.001 ether}();
                    return;
                }
                else
                {
                    b.Ulost();
                    a.Uwon{value: msg.value - 0.001 ether}();
                    return;
                }
            }
            
            if(!sticks)
            {
                sticksLeft = false;
            }
        }
            
        if(playerATurn)
        {
            b.Ulost();
            a.Uwon{value: msg.value - 0.001 ether}();
            return;
        }
        else
        {
            a.Ulost();
            b.Uwon{value: msg.value - 0.001 ether}();
            return;
        }
    }
        
    function validPile(uint pile) internal view returns(bool)
    {
        if(pile < boardGame.length && pile >= 0)
        {
            return true;
        }
        return false;
    }
        
    function validQuantity(uint pile, uint256 quantity) internal view returns(bool)
    {
        if(quantity <= 0)
        {
            return false;
        }
            
        if(quantity > boardGame[pile])
        {
            return false;
        }
        return true;
    }
}

contract TrackingNimPlayer is NimPlayer
{
    uint losses=0;
    uint wins=0;
    uint faults=0;
    // Given a set of piles, return a pile number and a quantity of items to remove
    function nextMove(uint256[] calldata) virtual override external returns (uint, uint256)
    {
        return(0,1);
    }
    // Called if you win, with your winnings!
    function Uwon() override external payable
    {
        wins += 1;
    }
    // Called if you lost :-(
    function Ulost() override external
    {
        losses += 1;
    }
    // Called if you lost because you made an illegal move :-(
    function UlostBadMove() override external
    {
        faults += 1;
    }
    
    function results() external view returns(uint, uint, uint, uint)
    {
        return(wins, losses, faults, address(this).balance);
    }
    
}

contract Boring1NimPlayer is TrackingNimPlayer
{
    // Given a set of piles, return a pile number and a quantity of items to remove
    function nextMove(uint256[] calldata piles) override external returns (uint, uint256)
    {
        for(uint i=0;i<piles.length; i++)
        {
            if (piles[i]>1) return (i, piles[i]-1);  // consumes all in a pile
        }
        for(uint i=0;i<piles.length; i++)
        {
            if (piles[i]>0) return (i, piles[i]);  // consumes all in a pile
        }
    }
}
