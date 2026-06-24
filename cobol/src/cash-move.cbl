       IDENTIFICATION DIVISION.
       PROGRAM-ID. CASH-MOVE.
       AUTHOR PASCAL KRIEG.

       ENVIRONMENT DIVISION.

       INPUT-OUTPUT SECTION.

       FILE-CONTROL.

           SELECT ACCOUNT-FILE
              ASSIGN TO "/app/cobol/data/accounts-ind.dat"
              ORGANIZATION IS INDEXED
              ACCESS MODE IS DYNAMIC
              RECORD KEY IS ACC-ID
              FILE STATUS IS WS-ACC-STATUS.

           SELECT TRANSACTION-FILE
              ASSIGN TO "/app/cobol/data/transactions.dat"
              ORGANIZATION IS LINE SEQUENTIAL.

           SELECT TR-COUNTER-FILE
              ASSIGN TO "/app/cobol/data/tr-counter.dat"
              ORGANIZATION IS LINE SEQUENTIAL.
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
           05 TR-ID         PIC X(6).
           05 TR-ACCOUNT-ID PIC X(4).
           05 TR-FROM-ID    PIC X(4).
           05 TR-TARGET-ID  PIC X(4).
           05 TR-CLIENT-ID  PIC X(4).
           05 TR-DATE       PIC X(10).
           05 TR-HOUR       PIC X(8).
           05 TR-TYPE       PIC X(10).
           05 TR-AMOUNT     PIC 9(10).
           05 TR-STATUS     PIC X(10) VALUE SPACES.
           05 TR-REASON     PIC X(100).

       FD TR-COUNTER-FILE.
       01 TR-COUNTER-RECORD   PIC 9(5).

       WORKING-STORAGE SECTION.

       01 WS-ACCOUNT-ID     PIC X(4).
       01 WS-CLIENT-ID      PIC X(4).
       01 WS-MOVE           PIC X(10).
       01 WS-AMOUNT         PIC 9(10).
       01 WS-STATUS         PIC X(10) VALUE 'PENDING'.
       01 WS-REASON         PIC X(100).

       01 WS-TR-COUNTER     PIC 9(5).

       01 WS-DATE           PIC 9(8).
       01 WS-TIME           PIC 9(6).

       01 WS-DATE-F         PIC X(10).
       01 WS-TIME-F         PIC X(8).

       01 WS-NEW-BALANCE    PIC 9(10).

       01 WS-ACC-STATUS     PIC XX.
       01 WS-TR-TYPE        PIC X.

       PROCEDURE DIVISION.

       MAIN.

           ACCEPT WS-CLIENT-ID  FROM ARGUMENT-VALUE
           ACCEPT WS-ACCOUNT-ID FROM ARGUMENT-VALUE
           ACCEPT WS-MOVE       FROM ARGUMENT-VALUE
           MOVE FUNCTION UPPER-CASE(FUNCTION TRIM(WS-MOVE)) TO WS-MOVE
           ACCEPT WS-AMOUNT     FROM ARGUMENT-VALUE
           ACCEPT WS-REASON     FROM ARGUMENT-VALUE

           ACCEPT WS-DATE FROM DATE YYYYMMDD
           ACCEPT WS-TIME FROM TIME

           PERFORM FORMAT-DATE
           PERFORM FORMAT-TIME
           
           PERFORM HANDLE-COUNTER
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

       HANDLE-COUNTER.

           OPEN I-O TR-COUNTER-FILE

           READ TR-COUNTER-FILE
               AT END
                   MOVE 0 TO WS-TR-COUNTER
               NOT AT END
                   MOVE TR-COUNTER-RECORD TO WS-TR-COUNTER
           END-READ

           ADD 1 TO WS-TR-COUNTER

           CLOSE TR-COUNTER-FILE

           OPEN OUTPUT TR-COUNTER-FILE
               MOVE WS-TR-COUNTER TO TR-COUNTER-RECORD
               WRITE TR-COUNTER-RECORD
           CLOSE TR-COUNTER-FILE.

       WRITE-TRANSACTION.
           OPEN EXTEND TRANSACTION-FILE

           STRING
              WS-TR-TYPE DELIMITED BY SIZE
              WS-TR-COUNTER DELIMITED BY SIZE
              INTO TR-ID
           END-STRING
           
           MOVE WS-ACCOUNT-ID TO TR-ACCOUNT-ID
           MOVE '0000' TO TR-FROM-ID
           MOVE '0000' TO TR-TARGET-ID
           MOVE WS-CLIENT-ID  TO TR-CLIENT-ID

           MOVE WS-DATE-F TO TR-DATE
           MOVE WS-TIME-F TO TR-HOUR

           MOVE WS-MOVE TO TR-TYPE
           MOVE WS-AMOUNT TO TR-AMOUNT
           MOVE WS-STATUS TO TR-STATUS
           MOVE WS-REASON TO TR-REASON

           WRITE TRANSACTION-RECORD
           CLOSE TRANSACTION-FILE.

       ABORT-MOVE.
           MOVE 'REJECTED' TO WS-STATUS
           MOVE 'R' TO WS-TR-TYPE
           PERFORM WRITE-TRANSACTION
           CLOSE ACCOUNT-FILE.

       FORMAT-DATE.

           MOVE WS-DATE(1:4) TO WS-DATE-F(1:4)
           MOVE "-" TO WS-DATE-F(5:1)
           MOVE WS-DATE(5:2) TO WS-DATE-F(6:2)
           MOVE "-" TO WS-DATE-F(8:1)
           MOVE WS-DATE(7:2) TO WS-DATE-F(9:2).

       FORMAT-TIME.

           MOVE WS-TIME(1:2) TO WS-TIME-F(1:2)
           MOVE ":" TO WS-TIME-F(3:1)
           MOVE WS-TIME(3:2) TO WS-TIME-F(4:2)
           MOVE ":" TO WS-TIME-F(6:1)
           MOVE WS-TIME(5:2) TO WS-TIME-F(7:2).
           