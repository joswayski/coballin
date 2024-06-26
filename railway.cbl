IDENTIFICATION DIVISION.
       PROGRAM-ID. COBOL-WEB-SERVER.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SPECIAL-NAMES.
           SYMBOLIC CHARACTERS SOH IS 1.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-SOCKET-DESCRIPTOR PIC 9(8) COMP.
       01 WS-CLIENT-SOCKET PIC 9(8) COMP.
       01 WS-BUFFER.
           05 WS-RECV-BUFFER PIC X(1024).
           05 WS-SEND-BUFFER PIC X(1024).
       01 WS-RECV-LENGTH PIC 9(8) COMP.
       01 WS-SEND-LENGTH PIC 9(8) COMP.
       01 WS-FLAGS PIC 9(8) COMP VALUE 0.
       01 WS-RESULT PIC S9(9) COMP.
       01 WS-SOCKADDR-IN.
           05 SIN-FAMILY PIC 9(4) COMP VALUE 2.
           05 SIN-PORT PIC 9(4) COMP VALUE 8080.
           05 SIN-ADDR PIC 9(8) COMP VALUE 0.
           05 SIN-ZERO PIC X(8) VALUE LOW-VALUES.
       
       PROCEDURE DIVISION.
       MAIN-PROCEDURE.
           PERFORM INITIALIZE-SERVER
           PERFORM ACCEPT-CONNECTIONS
           PERFORM CLEANUP
           STOP RUN.

       INITIALIZE-SERVER.
           CALL "socket" USING BY VALUE 2 
                               BY VALUE 1 
                               BY VALUE 6 
               RETURNING WS-SOCKET-DESCRIPTOR
           IF WS-SOCKET-DESCRIPTOR < 0
               DISPLAY "Failed to create socket"
               STOP RUN
           END-IF
           
           CALL "bind" USING BY VALUE WS-SOCKET-DESCRIPTOR
                             BY REFERENCE WS-SOCKADDR-IN
                             BY VALUE LENGTH OF WS-SOCKADDR-IN
               RETURNING WS-RESULT
           IF WS-RESULT < 0
               DISPLAY "Failed to bind socket"
               STOP RUN
           END-IF
           
           CALL "listen" USING BY VALUE WS-SOCKET-DESCRIPTOR
                               BY VALUE 5
               RETURNING WS-RESULT
           IF WS-RESULT < 0
               DISPLAY "Failed to listen on socket"
               STOP RUN
           END-IF
           DISPLAY "Server listening on port 8080".

       ACCEPT-CONNECTIONS.
           PERFORM UNTIL EXIT
               CALL "accept" USING BY VALUE WS-SOCKET-DESCRIPTOR
                                   BY REFERENCE WS-SOCKADDR-IN
                                   BY REFERENCE LENGTH OF WS-SOCKADDR-IN
                   RETURNING WS-CLIENT-SOCKET
               IF WS-CLIENT-SOCKET < 0
                   DISPLAY "Failed to accept connection"
                   EXIT PERFORM
               END-IF
               
               PERFORM HANDLE-REQUEST
           END-PERFORM.

       HANDLE-REQUEST.
           MOVE SPACES TO WS-RECV-BUFFER
           CALL "recv" USING BY VALUE WS-CLIENT-SOCKET
                             BY REFERENCE WS-RECV-BUFFER
                             BY VALUE LENGTH OF WS-RECV-BUFFER
                             BY VALUE WS-FLAGS
               RETURNING WS-RECV-LENGTH
           IF WS-RECV-LENGTH < 0
               DISPLAY "Failed to receive data"
               EXIT PARAGRAPH
           END-IF
           
           MOVE 
               "HTTP/1.1 200 OK" & X"0D0A" &
               "Content-Type: text/html" & X"0D0A" &
               "Connection: close" & X"0D0A" &
               X"0D0A" &
               "<html><body><h1>Railway is awesome :)</h1></body></html>"
               TO WS-SEND-BUFFER
           MOVE LENGTH OF FUNCTION TRIM(WS-SEND-BUFFER) TO WS-SEND-LENGTH
           
           CALL "send" USING BY VALUE WS-CLIENT-SOCKET
                             BY REFERENCE WS-SEND-BUFFER
                             BY VALUE WS-SEND-LENGTH
                             BY VALUE WS-FLAGS
               RETURNING WS-RESULT
           IF WS-RESULT < 0
               DISPLAY "Failed to send response"
           END-IF
           
           CALL "close" USING BY VALUE WS-CLIENT-SOCKET.

       CLEANUP.
           CALL "close" USING BY VALUE WS-SOCKET-DESCRIPTOR.
