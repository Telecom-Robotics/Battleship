! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: Battleship.client.factor.protocol
Battleship.client.factor.strategies kernel sequences sets
;
IN: Battleship.client.factor.strategies.placement.tomo

SINGLETON: tomo-placement
M: tomo-placement place-ship ( already-placed-ships new-ship-size -- ship )
    drop members length 0 "V" ship boa ;


