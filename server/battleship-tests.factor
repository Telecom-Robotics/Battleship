! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors Battleship.server kernel memoize tools.test ;
IN: Battleship.server.tests

[ { { { 0 0 } { 0 1 } } { { 1 0 } { 1 1 } } } ] [ { 1 1 } 1 (calc-lines) ] unit-test
[ { 
  { { 0 0 } { 0 1 } }
  { { 1 0 } { 1 1 } }
  { { 0 0 } { 1 0 } }
  { { 0 1 } { 1 1 } } } ] [ { 1 1 } { 1 1 } calc-lines ] unit-test
MEMO: test-board ( -- test-board ) <test-board> ;

[ t ] [ { 1 2 } test-board ships>> find-ship-part drop >boolean ] unit-test
[ f ] [ { 1 1 } test-board ships>> find-ship-part drop >boolean ] unit-test
[ f ] [ { 1 1 } test-board ships>> find-ship-part drop >boolean ] unit-test
