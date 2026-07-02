       IDENTIFICATION DIVISION.
       PROGRAM-ID. PAYMENTS-BATCH.
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

           SELECT REPORT-FILE
              ASSIGN TO "cobol/data/payment-report.txt"
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
           05 TR-ID          PIC 9(8).
           05 TR-ACCOUNT-ID  PIC X(4).
           05 TR-FROM-ID     PIC X(4).
           05 TR-TO-ID       PIC X(4).
           05 TR-CLIENT-ID   PIC X(4).
           05 TR-DATE        PIC X(10).
           05 TR-HOUR        PIC X(8).
           05 TR-TYPE        PIC X(10).
           05 TR-AMOUNT      PIC 9(10).
           05 TR-STATUS      PIC X(10).
           05 TR-REASON      PIC X(100).

       FD REPORT-FILE.
       01 REPORT-LINE PIC X(80).

       WORKING-STORAGE SECTION.

       01 EOF                PIC X VALUE "N".
       01 WS-TR-CONTENT      PIC X(255).
       01 WS-COMMA           PIC X.

       01 WS-TR-FS           PIC XX.
       01 WS-ACC-FS          PIC XX.

       01 WS-FORMATED-DATE   PIC 9(10).
       01 WS-FORMATED-TIME   PIC 9(8).

       01 WS-NB-PAYMENTS     PIC 9(3) VALUE ZERO.
       01 WS-PROCESS-OK      PIC X VALUE 'Y'.

       PROCEDURE DIVISION.

       MAIN.
           
           CALL "DATETIME"
              USING WS-FORMATED-DATE
                    WS-FORMATED-TIME

           MOVE "00" TO WS-TR-FS
           OPEN I-O TRANSACTION-FILE
           MOVE "00" TO WS-ACC-FS
           OPEN I-O ACCOUNT-FILE

           PERFORM SCAN-TRANSACTIONS

           CLOSE TRANSACTION-FILE
           CLOSE ACCOUNT-FILE

           IF WS-NB-PAYMENTS > 0
              CLOSE REPORT-FILE
           END-IF

           STOP RUN.
       
       SCAN-TRANSACTIONS.

           PERFORM UNTIL EOF = "Y"
               READ TRANSACTION-FILE
                   AT END
                      MOVE "Y" TO EOF
                   NOT AT END
                      IF FUNCTION TRIM(TR-STATUS) = 'PENDING'
                      AND FUNCTION TRIM(TR-TYPE) = 'PAYMENT'

      * ------------------Writing header -------------------                
                         IF WS-NB-PAYMENTS = 0
                             OPEN EXTEND REPORT-FILE
                             MOVE ALL "=" TO REPORT-LINE
                             WRITE REPORT-LINE
                             MOVE SPACES TO REPORT-LINE
                             STRING
                                 "Batch "
                                 WS-FORMATED-DATE DELIMITED BY SIZE
                                 SPACE
                                 WS-FORMATED-TIME DELIMITED BY SIZE
                                 INTO REPORT-LINE
                             END-STRING
                             
                             WRITE REPORT-LINE
                             MOVE ALL "-" TO REPORT-LINE
                             WRITE REPORT-LINE
                             MOVE SPACES TO REPORT-LINE

                         END-IF

                         PERFORM HANDLE-ACCOUNT
                         IF WS-PROCESS-OK = 'Y'
                             PERFORM UPDATE-TRANSACTION
                         END-IF
                      END-IF
               END-READ
               
           END-PERFORM
           PERFORM CLOSE-REPORT.

       UPDATE-TRANSACTION.
           
           MOVE 'EXECUTED' TO TR-STATUS

           REWRITE TRANSACTION-RECORD
              INVALID KEY
                 STRING
                 "Transaction " DELIMITED BY SIZE
                 TR-ID DELIMITED BY SIZE
                 " - " DELIMITED BY SIZE
                 TR-ACCOUNT-ID DELIMITED BY SIZE
                 " - " DELIMITED BY SIZE
                 TR-AMOUNT DELIMITED BY SIZE
                 " - ABORTED: Transaction key can't be found "
                 DELIMITED BY SIZE
                 INTO REPORT-LINE
               END-STRING

               WRITE REPORT-LINE
                 STOP RUN
           END-REWRITE

           ADD 1 TO WS-NB-PAYMENTS

           STRING
               "Transaction " DELIMITED BY SIZE
               TR-ID DELIMITED BY SIZE
               " - " DELIMITED BY SIZE
               TR-ACCOUNT-ID DELIMITED BY SIZE
               " - " DELIMITED BY SIZE
               TR-AMOUNT DELIMITED BY SIZE
               " - EXECUTED" DELIMITED BY SIZE
               INTO REPORT-LINE
           END-STRING
           
           WRITE REPORT-LINE.

       HANDLE-ACCOUNT.
           
           MOVE 'Y' TO WS-PROCESS-OK
           
           IF WS-ACC-FS NOT = "00"
              STRING
                 "Transaction " DELIMITED BY SIZE
                 TR-ID DELIMITED BY SIZE
                 " - " DELIMITED BY SIZE
                 TR-ACCOUNT-ID DELIMITED BY SIZE
                 " - " DELIMITED BY SIZE
                 TR-AMOUNT DELIMITED BY SIZE
                 " - ABORTED: accounts file can't be opened "
                 DELIMITED BY SIZE
                 INTO REPORT-LINE
               END-STRING

               WRITE REPORT-LINE
               MOVE 'N' TO WS-PROCESS-OK
           END-IF

           MOVE TR-ACCOUNT-ID TO ACC-ID
           READ ACCOUNT-FILE
               KEY IS ACC-ID
               INVALID KEY
                   STRING
                       "Transaction " DELIMITED BY SIZE
                       TR-ID DELIMITED BY SIZE
                       " - " DELIMITED BY SIZE
                       TR-ACCOUNT-ID DELIMITED BY SIZE
                       " - " DELIMITED BY SIZE
                       TR-AMOUNT DELIMITED BY SIZE
                       " - ABORTED: account doesn't exists "
                       DELIMITED BY SIZE
                       INTO REPORT-LINE
                   END-STRING

                   WRITE REPORT-LINE
                   MOVE 'N' TO WS-PROCESS-OK
           END-READ

           IF WS-PROCESS-OK = 'Y'
              SUBTRACT TR-AMOUNT FROM ACC-BALANCE
              REWRITE ACCOUNT-RECORD
                  INVALID KEY
                      STRING
                          "Transaction " DELIMITED BY SIZE
                          TR-ID DELIMITED BY SIZE
                          " - " DELIMITED BY SIZE
                          TR-ACCOUNT-ID DELIMITED BY SIZE
                          " - " DELIMITED BY SIZE
                          TR-AMOUNT DELIMITED BY SIZE
                          " - ABORTED: Rewrite can't be done"
                          DELIMITED BY SIZE
                          INTO REPORT-LINE
                      END-STRING

                      WRITE REPORT-LINE
              END-REWRITE
           END-IF.
       
       CLOSE-REPORT.

           IF WS-NB-PAYMENTS > 0

               MOVE ALL "-" TO REPORT-LINE
               WRITE REPORT-LINE
               MOVE " " TO REPORT-LINE

               STRING
                   "TOTAL PROCESSED PAYMENTS : "
                   WS-NB-PAYMENTS
                   DELIMITED BY SIZE
                   INTO REPORT-LINE
               END-STRING
               WRITE REPORT-LINE
           
               
               

               MOVE ALL "=" TO REPORT-LINE
               WRITE REPORT-LINE
           
           END-IF.
