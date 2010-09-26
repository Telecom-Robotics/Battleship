! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays battleship.types concurrency.messaging
io kernel math.parser sequences threads ;
IN: battleship.arbiter

CONSTANT: ship-config { 5 4 3 2 }

: dispatch ( data dst -- ) swap ":" glue print ;
: other-player>> ( game -- player )
    dup [ current-player>> ] [ player1>> ] bi =
    [ player2>> ] [ player1>> ] if ;
: swap-players ( game -- )
    dup [ current-player>> ] [ player1>> ] bi = 
    [ dup player2>> ] [ dup player1>> ] if
    >>current-player drop ;
: ((player-receive)) ( player msg -- data/f )
    swap over [ name>> ] [ source>> ] bi* = [ data>> ] [ drop f ] if ;
: (player-receive) ( player -- data/f ) receive ((player-receive)) ;
: player-receive ( player -- data )
    [ (player-receive) dup ] curry [ drop ] until ;

: parse-position ( data -- pos ) drop { 5 5 } ;
: get-shoot-answer ( player -- pos )
    dup player-receive parse-position [ nip ] [ get-shoot-answer ] if* ;
: prompt-shoot ( game -- )
    { [ current-player>> name>> "FIRE" swap dispatch ]
    [ current-player>> get-shoot-answer ]
    [ other-player>> ships>> fire ]
    [ current-player>> name>> dispatch ] } cleave ;
: game-over? ( game -- winner/f loser/f )
    {
    { [ dup player1>> player-dead? ] [ [ player2>> ] [ player1>> ] bi ] }
    { [ dup player2>> player-dead? ] [ [ player1>> ] [ player2>> ] bi ] }
    [ drop f f ] } cond ;

: signal-end-game ( winner loser -- )
    "YOU WIN!" "YOU LOSE" [ swap name>> dispatch ] bi-curry@ bi* ;
: unregister-game ( game -- ) drop ;
: end-game ( game winner loser -- )
    signal-end-game 
    unregister-game ;
DEFER: game-loop
: ?continue-game ( game -- )
    dup game-over? [ end-game ] [ drop game-loop ] if* ;
: game-loop ( game -- ) [ prompt-shoot ] [ swap-players ] [ ?continue-game ] tri ;

: ship-request ( ship -- str )
    number>string "SHIP" prepend ;
: <test-ship> ( # -- ship )
    dup 2array f ship-part boa 1array ship boa ;
: parse-ship ( # str -- ship ) drop <test-ship> ;
: add-ship ( player ship -- ) [ suffix ] curry change-ships drop ;
: send-ship-request ( player ship -- )
    ship-request swap name>> dispatch ;
: get-ship-answer ( player ship -- )
    over player-receive
    dupd parse-ship [ nip add-ship ] [ get-ship-answer ] if* ;
: prompt-for-ship ( player ship -- )
    [ send-ship-request ] 
    [ get-ship-answer ] 2bi ;
: (prompt-for-ships) ( player -- )
    ship-config [ prompt-for-ship ] with each ;
! TODO prompt for ships in 2 threads, one for each player
: prompt-for-ships ( game -- )
    [ player1>> ] [ player2>> ] bi 2array [ (prompt-for-ships) ] each ;
: do-game ( game -- )
    [ prompt-for-ships ] [ game-loop ] bi ;
: arbiter-name ( game -- name )
    players-list "Arbiter for " prepend ;
: <arbiter> ( game -- arbiter )
    [ [ do-game ] curry ] [ arbiter-name ] bi spawn ;
