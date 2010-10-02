! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: Battleship.client.factor.protocol
Battleship.client.factor.strategies arrays assocs kernel
math sequences ;
IN: Battleship.client.factor.strategies.attack.tomo

SINGLETON: tomo-attack
M: tomo-attack fire ( previous-shots -- {x,y} )
    keys length board-size first /mod swap 2array ;
