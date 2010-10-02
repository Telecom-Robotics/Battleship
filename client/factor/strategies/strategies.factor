! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel
macros namespaces random
Battleship.client.factor ;
IN: Battleship.client.factor.strategies

SYMBOL: placement-strategy
HOOK: place-ship placement-strategy ( already-placed-ships new-ship-size -- ship )

SYMBOL: attack-strategy
HOOK: fire attack-strategy ( previous-shots -- {x,y} )

: with-attack-strategy ( strategy quot -- )
    [ attack-strategy ] dip with-variable ; inline
: with-placement-strategy ( strategy quot -- )
    [ placement-strategy ] dip with-variable ; inline

M: f place-ship "You must choose a strategy" throw ;
M: f fire "You must choose a strategy" throw ;
