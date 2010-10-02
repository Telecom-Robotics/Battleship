! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
IN: Battleship.client.factor.protocol

TUPLE: ship x y orientation ;
TUPLE: shot {x,y} answer ;

CONSTANT: protocol-start "NEWGAME"
CONSTANT: protocol-fire "FIRE"
CONSTANT: protocol-win "YOU WIN"
CONSTANT: protocol-lose "YOU LOSE"
CONSTANT: protocol-ship "SHIP"
CONSTANT: protocol-horizontal "H"
CONSTANT: protocol-separator ";"
CONSTANT: protocol-OK "OK"

CONSTANT: board-size { 10 10 }

