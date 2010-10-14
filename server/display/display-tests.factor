! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test Battleship.server.display ;
IN: Battleship.server.display.tests

[ { { { 0 0 } { 0 1 } } { { 1 0 } { 1 1 } } } ] [ { 1 1 } 1 (calc-lines) ] unit-test
[ { 
  { { 0 0 } { 0 1 } }
  { { 1 0 } { 1 1 } }
  { { 0 0 } { 1 0 } }
  { { 0 1 } { 1 1 } } } ] [ { 1 1 } { 1 1 } calc-lines ] unit-test
