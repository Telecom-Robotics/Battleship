! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: Battleship.server.arbiter Battleship.server.types
accessors sequences tools.test ;
IN: Battleship.server.arbiter.tests

[ { { 2 4 } { 3 4 } } ] [ 2 "SHIP;2;4;H" parse-ship parts>> [ position>> ] map ] unit-test

[ { { 2 4 } { 2 5 } { 2 6 } } ] [ 3 "SHIP;2;4;V" parse-ship parts>> [ position>> ] map ] unit-test

[ { 1 1 } ] [ "FIRE;1;1" parse-position ] unit-test

[ t ] [ 3 "SHIP;2;4;V" parse-ship 3 "SHIP;2;4;H" parse-ship (ship-overlaps?) ] unit-test
[ f ] [ 3 "SHIP;2;4;V" parse-ship 3 "SHIP;3;4;H" parse-ship (ship-overlaps?) ] unit-test
