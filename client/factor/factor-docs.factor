! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax io.encodings.ascii io.sockets
kernel math quotations strings Battleship.client.factor.strategies.all ;
IN: Battleship.client.factor

HELP: play-battleship
{ $description "Plays a Battleship game. This must be called"
" with attack and placement strategies. "
"See " { $vocab-link "Battleship.client.factor.strategy" } " to know how to set the strategies."
$nl
"If you want to connect to a server, use " { $link with-ascii-client } "." 
$nl
"Here's an example:"
{ $code "USING: Battleship.client.factor Battleship.client.factor.strategies.all threads ;"
"[ \"localhost\" 1234 [ [ play-battleship ] with-random-strategy ] with-ascii-client ]"
"\"Battleship Player\" spawn" }
} ;

HELP: with-ascii-client
{ $values
    { "host" string } { "port" integer } { "quot" quotation }    
}
{ $description "Simple wrapper around " { $link with-client }
" which always uses " { $link ascii } " encoding and directly takes the " { $snippet "host" } " and " { $snippet "port" }
" as arguments." } ;

ARTICLE: "Battleship.client.factor" "Battleship client"
"The " { $vocab-link "Battleship.client.factor" } " implements a simple client to play Battleship."
"To launch the client, look at the following word:"
{ $subsections 
    play-battleship
}
"The client must know a strategy to play. Strategies are described in the " { $vocab-link "Battleship.client.factor.strategies" } " vocabulary."
;

ABOUT: "Battleship.client.factor"
