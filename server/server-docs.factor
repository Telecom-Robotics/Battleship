! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel strings ;
IN: Battleship.server

HELP: (calc-lines)
{ $values
    { "dim" null } { "n" null }
    { "lines" null }
}
{ $description "" } ;

HELP: (find-ship-part)
{ $values
    { "pos" null } { "ship" null }
    { "ship-part/f" null }
}
{ $description "" } ;

HELP: <Battleship-server>
{ $values
    { "lobby-thread" null } { "port" null }
    { "threaded-server" null }
}
{ $description "" } ;

HELP: <battleship-gadget>
{ $values
    { "game" null }
    { "gadget" null }
}
{ $description "" } ;

HELP: <battleship-game>
{ $values
    { "players" null }
    { "game" null }
}
{ $description "" } ;

HELP: <lower-track>
{ $values
    { "player1" null } { "player2" null }
    { "track" null }
}
{ $description "" } ;

HELP: <upper-track>
{ $values
    { "player1" null } { "player2" null }
    { "track" null }
}
{ $description "" } ;

HELP: calc-lines
{ $values
    { "dim" null } { "size" null }
    { "lines" null }
}
{ $description "" } ;

HELP: client-id
{ $values
        { "id" null }
}
{ $description "" } ;

HELP: dispatch
{ $values
    { "data" null } { "dst" null }    
}
{ $description "" } ;

HELP: draw-grid
{ $values
    { "gadget" null }    
}
{ $description "" } ;

HELP: draw-line
{ $values
    { "{p1,p2}" null }    
}
{ $description "" } ;

HELP: draw-missed
{ $values
    { "gadget" null }    
}
{ $description "" } ;

HELP: draw-position
{ $values
    { "gadget" null } { "pos" null }    
}
{ $description "" } ;

HELP: draw-ship
{ $values
    { "gadget" null } { "ship" null }    
}
{ $description "" } ;

HELP: draw-ships
{ $values
    { "game" null }    
}
{ $description "" } ;

HELP: eth-clients
{ $var-description "" } ;

HELP: find-ship-part
{ $values
    { "pos" null } { "ships" null }
    { "ship/f" null } { "ship-part/f" null }
}
{ $description "" } ;

HELP: fire
{ $values
    { "pos" null } { "player" null }
    { "str" string }
}
{ $description "" } ;

HELP: handle
{ $values
    { "source" null } { "lobby-thread" null }
    { "?" boolean }
}
{ $description "" } ;

HELP: handle-battleship-client
{ $values
    { "lobby-thread" null }    
}
{ $description "" } ;

HELP: hit
{ $values
    { "ship" null } { "ship-part" null }
    { "str" string }
}
{ $description "" } ;

HELP: line
{ $values
    { "n" null } { "len" null }
    { "{p1,p2}" null }
}
{ $description "" } ;

HELP: player-dead?
{ $values
    { "player" null }
    { "?" boolean }
}
{ $description "" } ;

HELP: player-playing?
{ $values
    { "player" null } { "game" null }
    { "?" boolean }
}
{ $description "" } ;

HELP: plouf
{ $values
    { "pos" null } { "player" null }    
}
{ $description "" } ;

HELP: rotate
{ $values
    { "lines" null }
    { "lines'" null }
}
{ $description "" } ;

HELP: setup-client
{ $values
    { "source" null }    
}
{ $description "" } ;

HELP: ship-color
{ $values
    { "ship-part" null }    
}
{ $description "" } ;

HELP: ship-dead?
{ $values
    { "ship" null }
    { "?" boolean }
}
{ $description "" } ;

HELP: spawn-listen-thread
{ $values
    { "lobby-thread" null } { "client-id" null }    
}
{ $description "" } ;

HELP: spawn-send-thread
{ $values
    { "client-id" null }    
}
{ $description "" } ;

HELP: start-eth-listen
{ $values
    { "lobby-thread" null } { "port" null }
    { "eth-server" null }
}
{ $description "" } ;

HELP: unregister-client
{ $values
    { "source" null }    
}
{ $description "" } ;

HELP: width/height
{ $values
    { "gadget" null }
    { "{width,height}" null }
}
{ $description "" } ;

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
