       IDENTIFICATION DIVISION.
       PROGRAM-ID. CASH-MOVE.
       AUTHOR PASCAL KRIEG.

       ENVIRONMENT DIVISION.

       INPUT-OUTPUT SECTION.

       FILE-CONTROL.

           SELECT ACCOUNT-FILE
              ASSIGN TO "cobol/data/accounts-ind.dat"
              ORGANIZATION IS INDEXED
              ACCESS MODE IS DYNAMIC
              RECORD KEY IS ACC-ID
              FILE STATUS IS WS-ACC-STATUS.

           SELECT TRANSACTION-FILE
              ASSIGN TO "cobol/data/transactions.dat"
              ORGANIZATION IS INDEXED
              ACCESS MODE IS DYNAMIC
              RECORD KEY IS TR-ID
              FILE STATUS IS WS-TR-FS.
              
       DATA DIVISION.

       FILE SECTION.

       FD ACCOUNT-FILE.
       01 ACCOUNT-RECORD.
           05 ACC-ID        PIC X(4).
           05 ACC-TYPE      PIC X(8).
           05 ACC-CLIENT-ID PIC X(4).
           05 ACC-IBAN      PIC X(27).
           05 ACC-BALANCE   PIC 9(10).
           05 ACC-CURRENCY  PIC X(3).

       FD TRANSACTION-FILE.
       01 TRANSACTION-RECORD.
           05 TR-ID         PIC X(8).
           05 TR-ACCOUNT-ID PIC X(4).
           05 TR-FROM-ID    PIC X(4).
           05 TR-TARGET-ID  PIC X(4).
           05 TR-CLIENT-ID  PIC X(4).
           05 TR-DATE       PIC X(10).
           05 TR-HOUR       PIC X(8).
           05 TR-TYPE       PIC X(10).
           05 TR-AMOUNT     PIC 9(10).
           05 TR-STATUS     PIC X(10).
           05 TR-REASON     PIC X(100).

       WORKING-STORAGE SECTION.

       01 WS-ACCOUNT-ID      PIC X(4).
       01 WS-CLIENT-ID       PIC X(4).
       01 WS-MOVE            PIC X(10).
       01 WS-AMOUNT          PIC 9(10).
       01 WS-STATUS          PIC X(10) VALUE 'PENDING'.
       01 WS-REASON          PIC X(100).
       
       01 WS-FORMATED-DATE   PIC 9(10).
       01 WS-FORMATED-TIME   PIC 9(8).
      
       01 WS-NEW-BALANCE     PIC 9(10).
      
       01 WS-ACC-STATUS      PIC XX.
       01 WS-TR-FS           PIC XX.
       01 WS-TR-TYPE         PIC X.
       01 WS-TR-COUNTER      PIC X(5).
       01 WS-TR-NUMBER       PIC 9(5).

       PROCEDURE DIVISION.

       MAIN.

           ACCEPT WS-CLIENT-ID  FROM ARGUMENT-VALUE
           ACCEPT WS-ACCOUNT-ID FROM ARGUMENT-VALUE
           ACCEPT WS-MOVE       FROM ARGUMENT-VALUE
           MOVE FUNCTION UPPER-CASE(FUNCTION TRIM(WS-MOVE)) TO WS-MOVE
           ACCEPT WS-AMOUNT     FROM ARGUMENT-VALUE
           ACCEPT WS-REASON     FROM ARGUMENT-VALUE

           CALL "DATETIME"
              USING WS-FORMATED-DATE
                    WS-FORMATED-TIME

           CALL "GETLASTTRID"
                 USING WS-TR-COUNTER

           PERFORM HANDLE-ACCOUNT
           PERFORM WRITE-TRANSACTION

           STOP RUN.

       HANDLE-ACCOUNT.

           MOVE WS-ACCOUNT-ID TO ACC-ID
           MOVE "00" TO WS-ACC-STATUS 

           OPEN I-O ACCOUNT-FILE
           IF WS-ACC-STATUS NOT = "00"
               DISPLAY "OPEN ERROR: " WS-ACC-STATUS
               PERFORM ABORT-MOVE
               STOP RUN
           END-IF
   
           READ ACCOUNT-FILE
               KEY IS ACC-ID
               INVALID KEY
                   DISPLAY '{"success":false,'
                   '"message":"Account not found"}'
                   PERFORM ABORT-MOVE
                   STOP RUN
           END-READ

           IF WS-MOVE = "DEPOSIT"
               ADD WS-AMOUNT TO ACC-BALANCE
               MOVE 'D' TO WS-TR-TYPE
           END-IF

           IF WS-MOVE = "WITHDRAW"
               MOVE 'W' TO WS-TR-TYPE
               IF ACC-BALANCE < WS-AMOUNT
                   DISPLAY '{"success":false,'
                   '"message":"Insufficient funds"}'
                   PERFORM ABORT-MOVE
                   STOP RUN
               END-IF
               SUBTRACT WS-AMOUNT FROM ACC-BALANCE
               
           END-IF

           MOVE ACC-BALANCE TO WS-NEW-BALANCE

           REWRITE ACCOUNT-RECORD
               INVALID KEY
                   DISPLAY '{"success":false,'
                   '"message":"Rewrite failed"}'
                   PERFORM ABORT-MOVE
                   STOP RUN
           END-REWRITE
      * ************** All tests passed *************
           DISPLAY '{"success":true,"accountId":"'
                   WS-ACCOUNT-ID
                   '","newBalance":"'
                   ACC-BALANCE
                   '"}'
           MOVE 'EXECUTED' TO WS-STATUS

           CLOSE ACCOUNT-FILE.
           
       WRITE-TRANSACTION.
           
           MOVE FUNCTION NUMVAL(WS-TR-COUNTER) TO WS-TR-NUMBER
           ADD 1 TO WS-TR-NUMBER
           
           OPEN I-O TRANSACTION-FILE
           IF WS-TR-FS NOT = "00"
               DISPLAY "OPEN ERROR: " WS-TR-FS
               PERFORM ABORT-MOVE
               STOP RUN
           END-IF

           STRING
              WS-TR-NUMBER DELIMITED BY SIZE
              WS-TR-TYPE DELIMITED BY SIZE
              '01' DELIMITED BY SIZE
              INTO TR-ID
           END-STRING
           
           MOVE WS-ACCOUNT-ID TO TR-ACCOUNT-ID
           MOVE '0000' TO TR-FROM-ID
           MOVE '0000' TO TR-TARGET-ID
           MOVE WS-CLIENT-ID  TO TR-CLIENT-ID

           MOVE WS-FORMATED-DATE TO TR-DATE
           MOVE WS-FORMATED-TIME TO TR-HOUR

           MOVE WS-MOVE TO TR-TYPE
           MOVE WS-AMOUNT TO TR-AMOUNT
           MOVE WS-STATUS TO TR-STATUS
           MOVE WS-REASON TO TR-REASON

           WRITE TRANSACTION-RECORD
           CLOSE TRANSACTION-FILE.           

       ABORT-MOVE.
           MOVE 'REJECTED' TO WS-STATUS
           PERFORM WRITE-TRANSACTION
           CLOSE ACCOUNT-FILE.
