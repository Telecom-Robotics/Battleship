! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel strings ;
IN: Battleship.server

ARTICLE: "Battleship.server" "Battleship server"
"The " { $vocab-link "Battleship.server" } " implements a Battleship server."
"The " { $vocab-link "Battleship.server.lobby" } " is responsible for "
"pairing players together."
$nl
"To start the tcp/ip server, run the following code :"
$nl
{ $code "USING: Battleship.server Battleship.server.lobby ;"
          "[ start-lobby 1234 start-eth-listen ] with-scope"
}
;

ABOUT: "Battleship.server"
