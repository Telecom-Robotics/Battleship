! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test Battleship.client ;
IN: Battleship.client.tests

[ "SHIP;1;2;H" ] [ 1 2 "H" ship boa ship>string ] unit-test
[ "FIRE;1;3" ] [ 1 3 fire>string ] unit-test
