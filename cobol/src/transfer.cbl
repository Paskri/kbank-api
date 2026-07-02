       IDENTIFICATION DIVISION.
       PROGRAM-ID. TRANSFER.
       AUTHOR PASCAL KRIEG.

       ENVIRONMENT DIVISION.

       INPUT-OUTPUT SECTION.

       FILE-CONTROL.

           SELECT ACCOUNT-FILE
              ASSIGN TO "cobol/data/accounts-ind.dat"
              ORGANIZATION IS INDEXED
              ACCESS MODE IS DYNAMIC
              RECORD KEY IS ACC-ID
              FILE STATUS IS WS-ACC-FS.

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

       01 WS-ACCOUNT-ID     PIC X(4).
       01 WS-TARGET-ID      PIC X(4).
       01 WS-CLIENT-ID      PIC X(4).
       01 WS-MOVE           PIC X(10).
       01 WS-AMOUNT         PIC 9(10).
       01 WS-STATUS         PIC X(10) VALUE 'PENDING'.
       01 WS-REASON         PIC X(100) VALUE SPACES.

       01 WS-TR-COUNTER     PIC 9(5).
       01 WS-TR-INDEX       PIC 9(2) VALUE 01.
       01 WS-TR-TYPE        PIC X VALUE 'T'.
       01 WS-TR-KEY         PIC X(8).

       01 WS-FORMATED-DATE  PIC 9(10).
       01 WS-FORMATED-TIME  PIC 9(8).

       01 WS-NEW-BALANCE    PIC 9(10).
       
       01 WS-TR-FS          PIC XX.
       01 WS-ACC-FS     PIC XX.

       01 WS-MSG            PIC X(100).


       



       PROCEDURE DIVISION.

       MAIN.

           ACCEPT WS-CLIENT-ID  FROM ARGUMENT-VALUE
           ACCEPT WS-ACCOUNT-ID FROM ARGUMENT-VALUE
           ACCEPT WS-TARGET-ID  FROM ARGUMENT-VALUE
           ACCEPT WS-MOVE       FROM ARGUMENT-VALUE
           MOVE FUNCTION UPPER-CASE(FUNCTION TRIM(WS-MOVE)) TO WS-MOVE
           ACCEPT WS-AMOUNT     FROM ARGUMENT-VALUE
           ACCEPT WS-REASON     FROM ARGUMENT-VALUE

           CALL "DATETIME"
              USING WS-FORMATED-DATE
                    WS-FORMATED-TIME

           CALL "GETLASTTRID"
                 USING WS-TR-COUNTER
           ADD 1 TO WS-TR-COUNTER

           MOVE "00" TO WS-TR-FS
           OPEN I-O TRANSACTION-FILE
           
           MOVE "00" TO WS-ACC-FS
           OPEN I-O ACCOUNT-FILE


      * Transfer - PENDING
           MOVE WS-ACCOUNT-ID TO ACC-ID
           PERFORM WRITE-TRANSACTION

      * ---- WITHDRAW
      * withdraw - PENDING
           MOVE 02 TO WS-TR-INDEX
           MOVE 'WITHDRAW' TO WS-MOVE
           PERFORM WRITE-TRANSACTION    
                 
      * withdraw handle
           PERFORM HANDLE-ACCOUNT

      * withdraw - EXECUTED
      *    MOVE 'EXECUTED' TO WS-STATUS 
           PERFORM UPDATE-TRANSACTION

      * ---- DEPOSIT
      * deposit - PENDING
           MOVE WS-TARGET-ID TO ACC-ID
           MOVE 'DEPOSIT' TO WS-MOVE
           MOVE 03 TO WS-TR-INDEX
           PERFORM WRITE-TRANSACTION

      * deposit handle     
           PERFORM HANDLE-ACCOUNT
      
      * deposit - EXECUTED   
           PERFORM UPDATE-TRANSACTION

      * ---- TRANSFER UPDATE      
      * Transfer - EXECUTED
           MOVE WS-ACCOUNT-ID TO ACC-ID
           MOVE 01 TO WS-TR-INDEX    
           PERFORM UPDATE-TRANSACTION

           DISPLAY '{"success":true,"from":"'
                   WS-ACCOUNT-ID
                   '","to":"'
                   WS-TARGET-ID
                   '","amount":"'
                   WS-AMOUNT
                   '","newBalance":"'
                   ACC-BALANCE
                   '"}'

           CLOSE ACCOUNT-FILE
           CLOSE TRANSACTION-FILE
           
           STOP RUN.

       WRITE-TRANSACTION.
                
           STRING
              WS-TR-COUNTER DELIMITED BY SIZE
              WS-TR-TYPE DELIMITED BY SIZE
              WS-TR-INDEX DELIMITED BY SIZE
              INTO TR-ID
           END-STRING

           MOVE ACC-ID TO TR-ACCOUNT-ID
           MOVE WS-ACCOUNT-ID TO TR-FROM-ID
           MOVE WS-TARGET-ID TO TR-TARGET-ID
           MOVE WS-CLIENT-ID  TO TR-CLIENT-ID

           MOVE WS-FORMATED-DATE TO TR-DATE
           MOVE WS-FORMATED-TIME TO TR-HOUR

           MOVE WS-MOVE TO TR-TYPE
           MOVE WS-AMOUNT TO TR-AMOUNT
           MOVE WS-STATUS TO TR-STATUS
           MOVE WS-REASON TO TR-REASON

           WRITE TRANSACTION-RECORD
              INVALID KEY
                 DISPLAY '{"WRITE ERROR": "'  
                          WS-TR-FS 
                          '"}'
           END-WRITE.

       UPDATE-TRANSACTION.
           
           STRING
              WS-TR-COUNTER DELIMITED BY SIZE
              WS-TR-TYPE DELIMITED BY SIZE
              WS-TR-INDEX DELIMITED BY SIZE
              INTO WS-TR-KEY
           END-STRING 
           
      ******** Positionning to avoid read error 23 ********
           MOVE WS-TR-KEY TO TR-ID    
           START TRANSACTION-FILE
               KEY IS EQUAL TO TR-ID
               INVALID KEY
                   DISPLAY '{"START ERROR": "' WS-TR-FS '"}'
                   STOP RUN
           END-START
               
           READ TRANSACTION-FILE
               NEXT RECORD
               AT END
                   DISPLAY '{"READ ERROR": "END AFTER START"}'
                   STOP RUN
           END-READ

           MOVE 'EXECUTED' TO TR-STATUS

           REWRITE TRANSACTION-RECORD
              INVALID KEY
                 DISPLAY '{"REWRITE ERROR": "' 
                          WS-TR-FS 
                          '"}'
                 STOP RUN
           END-REWRITE.

       HANDLE-ACCOUNT.

           IF WS-ACC-FS NOT = "00"
              STRING
                 '{"OPEN ERROR": "' DELIMITED BY SIZE
                 WS-ACC-FS DELIMITED BY SIZE
                 '"}' DELIMITED BY SIZE
                 INTO WS-MSG
              END-STRING
           
              DISPLAY WS-MSG
              STOP RUN
           END-IF
   
           READ ACCOUNT-FILE
               KEY IS ACC-ID
               INVALID KEY
                   DISPLAY '{"success":false,'
                   '"message":"Account not found"}'
                   PERFORM ABORT-TRANSFER
                   STOP RUN
           END-READ

           IF WS-MOVE = "DEPOSIT"
               ADD WS-AMOUNT TO ACC-BALANCE
           END-IF

           IF WS-MOVE = "WITHDRAW"
               IF ACC-BALANCE < WS-AMOUNT
                   DISPLAY '{"success":false,'
                   '"message":"Insufficient funds"}'
                   PERFORM ABORT-TRANSFER
                   STOP RUN
               END-IF
               SUBTRACT WS-AMOUNT FROM ACC-BALANCE
           END-IF

           MOVE ACC-BALANCE TO WS-NEW-BALANCE.

           REWRITE ACCOUNT-RECORD
               INVALID KEY
                   DISPLAY '{"success":false,'
                   '"message":"Rewrite failed"}'
                   PERFORM ABORT-TRANSFER
                   STOP RUN
           END-REWRITE.

       ABORT-TRANSFER.
           MOVE 'REJECTED' TO WS-STATUS
           PERFORM UPDATE-TRANSACTION

           CLOSE ACCOUNT-FILE.
                          