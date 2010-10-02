! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel quotations ;
IN: Battleship.client.factor.strategies

HELP: attack-strategy
{ $var-description "This variable should hold the desired attack strategy" } ;

HELP: fire
{ $values
    { "previous-shots" hashtable }
    { "{x,y}" pair }
}
{ $description "This word must be implemented to create new strategies. "
$nl
{ $snippet "Previous-shots" } " is a hashtable mapping pairs of integer to strings."
" These strings are the answers of the server to the shots. They are defined in the protocol : TOUCHE, TOUCHE-COULE or RATE. "
$nl
{ $snippet "{x,y}" } " must be a pair of integers in the board range. The board size is define in " { $vocab-link "Battleship.client.factor.protocol" } "." 
} ;

HELP: place-ship
{ $values
    { "already-placed-ships" sequence } { "new-ship-size" integer }
    { "ship" ship }
}
{ $description "This word must be implemented to create new strategies. Ships must be in the board and must not overlap"
$nl
{ $snippet "Already-placed-ships" } " is a sequence of previously placed " { $link ship } "s."
$nl
{ $snippet "New-ship-size" } " is " { $instance integer } "."
$nl
{ $snippet "Ship" } " must be " { $instance ship } "." 
}
;

HELP: placement-strategy
{ $var-description "This variable should hold the desired attack strategy" } ;

HELP: with-attack-strategy
{ $values
    { "strategy" singleton-class } { "quot" quotation }    
}
{ $description "See definition." } ;

HELP: with-placement-strategy
{ $values
    { "strategy" singleton-class } { "quot" quotation }    
}
{ $description "See definition." } ;

ARTICLE: "Battleship.client.factor.strategies" "Battleship strategies"
"The " { $vocab-link "Battleship.client.factor.strategies" } " vocabulary defines the words that must be implemented"
" in order to create a new strategy : "
{ $subsections 
    fire
    place-ship
}
"Strategies are set with " { $link with-attack-strategy } " and " { $link with-random-strategy } "."
$nl
"New strategies should be added to the " { $vocab-link "Battleship.client.factor.strategies.all" } " vocabulary, "
" so that they can then be used in the " { $link with-random-strategy } " word."
;

ABOUT: "Battleship.client.factor.strategies"
