! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: Battleship.server Battleship.server.types accessors
arrays combinators combinators.short-circuit
concurrency.messaging io kernel locals math math.parser
sequences sets splitting threads ;
IN: Battleship.server.arbiter

CONSTANT: ship-config { 5 4 }

: log-pckt ( pckt -- ) [ source>> ] [ data>> ] bi "===> " glue print ;

: other-player>> ( game -- player )
    dup [ current-player>> ] [ player1>> ] bi =
    [ player2>> ] [ player1>> ] if ;
: swap-players ( game -- )
    dup [ current-player>> ] [ player1>> ] bi =
    [ dup player2>> ] [ dup player1>> ] if
    >>current-player drop ;
: ((player-receive)) ( player msg -- data/f )
    swap over [ name>> ] [ source>> ] bi* = [ data>> ] [ drop f ] if ;
: (player-receive) ( player -- data/f ) receive dup log-pckt ((player-receive)) ;
: player-receive ( player -- data )
    [ (player-receive) dup ] curry [ drop ] until ;
: good-position? ( p -- ? )
    dup length 2 = [ BOARD-SIZE [ { [ drop 0 >= ] [ < ] } 2&& ] 2all? ]
    [ drop f ] if ;
: sanitize-position ( p -- p/f )
    dup good-position? [ drop f ] unless ;
: parse-position ( data -- pos/f )
    ";" split
    dup { [ length 3 = ] [ first "FIRE" = ] } 1&&
    [ rest [ string>number ] map sift sanitize-position ] [ drop f ] if ;
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
DEFER: game-loop
: ?continue-game ( game -- )
    dup game-over? [ signal-end-game drop ] [ drop game-loop ] if* ;
: game-loop ( game -- ) [ prompt-shoot ] [ swap-players ] [ ?continue-game ] tri ;

: ship-request ( ship -- str )
    number>string "SHIP;" prepend ;
: <test-ship> ( # -- ship )
    dup 2array f ship-part boa 1array ship boa ;
:: ship-in-map? ( # x y orientation -- ? )
   { [ x y 2array good-position? ]
     [ orientation "H" = [ x # + y ] [ x y # + ] if
     2array good-position? ]
   } 0&& ;
:: (ship-points) ( # x y orientation -- seq/f )
    # x y orientation ship-in-map? [
        # iota
        orientation "H" = [
            [ x + y 2array ] map ] [
            [ x swap y + 2array ] map ]
        if ] [ f ] if ;
:: ship-points ( # x y orientation -- seq/f )
    x y [ string>number ] bi@ :> ( X Y )
    X Y and [ # X Y orientation (ship-points)
    ] [ f ] if ;
: build-ship ( # x y orientation -- ship/f )
    ship-points [ [ <ship-part> ] map <ship> ] [ f ] if* ;
: parse-ship ( # str -- ship/f )
    ";" split
    dup { [ length 4 = ] [ first "SHIP" = ] [ fourth { "H" "V" } member? ] } 1&&
    [ rest first3 build-ship ] [ 2drop f ] if ;
: add-ship ( player ship -- ) [ suffix ] curry change-ships drop ;
: send-ship-request ( player ship -- )
    ship-request swap name>> dispatch ;
: (ship-overlaps?) ( ship1 ship2 -- ? )
    [ parts>> [ position>> ] map ] bi@ intersect empty? not ;
: ship-overlaps? ( player ship -- ? )
    [ ships>> ] dip [ (ship-overlaps?) ] curry any? ;
: get-ship-answer ( player ship -- )
    over player-receive
    dupd parse-ship [ 
        3dup nip ship-overlaps? [ drop get-ship-answer ] [ nip add-ship ] if
    ] [
        get-ship-answer ] if* ;
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
: <arbiter> ( end-quot game -- arbiter )
    [ [ do-game ] curry prepose ] [ arbiter-name ] bi spawn ;

: launch-arbiter ( end-quot game -- )
    [ <arbiter> ] keep arbiter<< ;

