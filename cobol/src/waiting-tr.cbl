       IDENTIFICATION DIVISION.
       PROGRAM-ID. WAITING-TR.
       AUTHOR PASCAL KRIEG.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT TRANSACTION-FILE 
              ASSIGN TO "cobol/data/transactions.dat"
              ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS TR-ID
               FILE STATUS IS WS-FS.

       DATA DIVISION.
       FILE SECTION.

       FD TRANSACTION-FILE.
       01 TRANSACTION-RECORD.
           05 TR-ID          PIC X(8).
           05 TR-ACCOUNT-ID  PIC X(4).
           05 TR-FROM-ID     PIC X(4).
           05 TR-TO-ID       PIC X(4).
           05 TR-CLIENT-ID   PIC X(4).
           05 TR-DATE        PIC X(10).
           05 TR-HOUR        PIC X(8).
           05 TR-TYPE        PIC X(10).
           05 TR-AMOUNT      PIC 9(10).
           05 TR-STATUS      PIC X(10) VALUE SPACES.
           05 TR-REASON      PIC X(100).

       WORKING-STORAGE SECTION.
       01 EOF                PIC X VALUE "N".
       01 WS-ACCOUNT-ID      PIC X(4).
       01 WS-TR-CONTENT      PIC X(255).
       01 WS-COMMA           PIC X.
       01 WS-FS              PIC XX.
       
       PROCEDURE DIVISION.

           ACCEPT WS-ACCOUNT-ID  FROM ARGUMENT-VALUE

           OPEN INPUT TRANSACTION-FILE
           DISPLAY '['
           PERFORM UNTIL EOF = "Y"
               READ TRANSACTION-FILE
                   AT END
                      MOVE "Y" TO EOF
                      MOVE ' ' TO WS-COMMA
                   NOT AT END
                      MOVE ',' TO WS-COMMA
                   
                   IF FUNCTION TRIM(TR-STATUS) = 'PENDING'
                   AND FUNCTION TRIM(TR-TYPE) = 'PAYMENT'
                       PERFORM SEND-JSON
                   END-IF
               END-READ
           END-PERFORM
           DISPLAY ']'
           CLOSE TRANSACTION-FILE

           STOP RUN.

       SEND-JSON.

           MOVE SPACES TO WS-TR-CONTENT   
              STRING '{"id": "' DELIMITED BY SIZE
                  TR-ID
                  '", "accountId": "' DELIMITED BY SIZE
                  TR-ACCOUNT-ID DELIMITED BY SIZE
                  '", "from": "' DELIMITED BY SIZE
                  TR-FROM-ID DELIMITED BY SIZE
                  '", "to": "' DELIMITED BY SIZE
                  TR-TO-ID DELIMITED BY SIZE
                  '", "clientId": "' DELIMITED BY SIZE
                  TR-CLIENT-ID DELIMITED BY SIZE
                  '", "date": "' DELIMITED BY SIZE
                  TR-DATE DELIMITED BY SIZE
                  '", "time": "' DELIMITED BY SIZE
                  TR-HOUR DELIMITED BY SIZE
                  '", "type": "' DELIMITED BY SIZE
                  TR-TYPE DELIMITED BY SIZE
                  '", "amount": "' DELIMITED BY SIZE
                  TR-AMOUNT DELIMITED BY SIZE
                  '", "status": "' DELIMITED BY SIZE
                  FUNCTION TRIM(TR-STATUS) DELIMITED BY SIZE
                  '", "reason": "' DELIMITED BY SIZE
                  FUNCTION TRIM(TR-REASON) DELIMITED BY SIZE
                  '"}' DELIMITED BY SIZE
                  WS-COMMA DELIMITED BY SIZE
                  INTO WS-TR-CONTENT
              END-STRING
           DISPLAY WS-TR-CONTENT.
