! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test Battleship.server.arbiter Battleship.server.types ;
IN: Battleship.server.arbiter.tests

[ T{ ship
    { parts
        {
            T{ ship-part { position { 2 4 } } }
            T{ ship-part { position { 3 4 } } }
        }
    }
} ] [ 2 "SHIP;2;4;H" parse-ship ] unit-test

[ T{ ship
    { parts
        {
            T{ ship-part { position { 2 4 } } }
            T{ ship-part { position { 2 5 } } }
            T{ ship-part { position { 2 6 } } }
        }
    }
} ] [ 3 "SHIP;2;4;V" parse-ship ] unit-test

[ { 1 1 } ] [ "FIRE;1;1" parse-position ] unit-test

[ t ] [ 3 "SHIP;2;4;V" parse-ship 3 "SHIP;2;4;H" parse-ship (ship-overlaps?) ] unit-test
[ f ] [ 3 "SHIP;2;4;V" parse-ship 3 "SHIP;3;4;H" parse-ship (ship-overlaps?) ] unit-test
