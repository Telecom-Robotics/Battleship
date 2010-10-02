! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: Battleship.client.factor.strategies
Battleship.client.factor.strategies.attack.random
Battleship.client.factor.strategies.attack.tomo
Battleship.client.factor.strategies.placement.tomo kernel
random ;
IN: Battleship.client.factor.strategies.all

CONSTANT: all-attack-strategies { tomo-attack random-attack }
CONSTANT: all-placement-strategies { tomo-placement }

: with-random-strategy ( quot -- )
    [ all-placement-strategies all-attack-strategies [ random ] bi@ ] dip
    [ with-attack-strategy ] 2curry with-placement-strategy ; inline


