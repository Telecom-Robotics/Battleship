! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: Battleship.server.types accessors concurrency.messaging
kernel namespaces sequences splitting strings threads xbee
xbee.api ;
QUALIFIED: xbee.dispatcher
QUALIFIED: xbee.api.simple
IN: Battleship.server.zigbee

: send-message ( lobby-thread recipient message -- )
   "Sending" plog dup plog swap dummy-message boa swap send ; 
: ?send-message ( lobby-thread recipient message -- rest )
    dup plog "\n" split1 [ [ send-message ] dip ] [ 2nip ] if* >string ;
: bufferize ( lobby-thread recipient -- )
    "" [ receive dup plog data>> >string append ?send-message t ] with with loop drop ; 
: <buffer-thread> ( lobby-thread recipient -- thread )
   [ [ bufferize ] 2curry ] [ >string nip ] 2bi spawn ;
: register-xbee-client ( lobby-thread recipient -- )
   [ <buffer-thread> ] [ nip xbee.dispatcher:register-recipient ] 2bi ;

! Command to launch on the XBee host:
!  socat TCP-LISTEN:4161,forever,fork,reuseaddr /dev/ttyUSB0,raw,b57600
! Then, supposedly, "JH" register-xbee-client 

: start-xbee ( -- )
    "jonction.enst.fr" 4161 <remote-xbee> xbee set
    enter-api-mode
    "CC" xbee.api.simple:set-my
    6 xbee.api.simple:set-retries
    xbee.dispatcher:start-dispatcher ;
