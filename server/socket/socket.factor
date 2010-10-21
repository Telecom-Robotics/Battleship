! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: Battleship.server.types accessors assocs calendar
calendar.format concurrency.messaging fry io io.encodings.ascii
io.servers io.streams.string kernel locals math.parser
namespaces prettyprint sequences system threads ;
FROM: io.sockets => remote-address local-address ;
IN: Battleship.server.socket

SYMBOL: eth-clients

: setup-client ( source -- )
    self swap eth-clients get-global set-at ;
: unregister-client ( source -- ) drop ;
:: handle ( source lobby-thread -- ? )
    readln dup empty? [ drop f ]
    [ [ "\n\r" member? not ] filter source [ dummy-message
    boa lobby-thread send t ] [ swap "===>" glue log ] 2bi ] if ;
: client-id ( -- id )
    remote-address get host>> 
    local-address get port>> number>string
    "|" glue nano-count number>string 
    ";" glue ;
: spawn-listen-thread ( lobby-thread client-id -- )
    [ swap [ handle ] 2curry ] [ ] bi spawn-server drop ;
: spawn-send-thread ( client-id -- )
    [ setup-client [ receive print flush t ] loop ] curry
    "Sending thread toto" spawn drop ;
: handle-battleship-client ( lobby-thread -- )
    client-id
    [ spawn-listen-thread ] [ spawn-send-thread ] 
    [ receive drop unregister-client ] tri ;
    

: <Battleship-server> ( lobby-thread port -- threaded-server )
    ascii <threaded-server>
        "Battleship-server" >>name
        swap >>insecure
        f >>timeout
        swap [ handle-battleship-client ] curry >>handler ;

: start-eth-listen ( lobby-thread port -- eth-server )
    H{ } clone eth-clients set-global
    <Battleship-server> start-server ;

