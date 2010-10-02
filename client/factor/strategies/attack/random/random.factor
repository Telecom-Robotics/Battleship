! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: Battleship.client.factor.protocol
Battleship.client.factor.strategies assocs kernel memoize
random sequences sequences.product sets ;
IN: Battleship.client.factor.strategies.attack.random

SINGLETON: random-attack
<PRIVATE
MEMO: possibilities ( -- possibilities )
    board-size [ iota ] map <product-sequence> ;
PRIVATE>
M: random-attack fire ( previous-shots -- {x,y} )
    possibilities swap keys diff random ;


