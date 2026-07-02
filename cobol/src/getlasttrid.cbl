       IDENTIFICATION DIVISION.
       PROGRAM-ID. GETLASTTRID.
       
       ENVIRONMENT DIVISION.
       
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
       
           SELECT TRANSACTION-FILE
               ASSIGN TO "cobol/data/transactions.dat"
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS TR-ID.
       
       DATA DIVISION.
       
       FILE SECTION.
       
       FD TRANSACTION-FILE.
       01 TRANSACTION-RECORD.

           05 TR-ID         PIC X(8).
           05 TR-ACCOUNT-ID PIC X(4).
           05 TR-FROM-ID    PIC X(4).
           05 TR-TO-ID      PIC X(4).
           05 TR-CLIENT-ID  PIC X(4).
           05 TR-DATE       PIC X(10).
           05 TR-HOUR       PIC X(8).
           05 TR-TYPE       PIC X(10).
           05 TR-AMOUNT     PIC 9(10).
           05 TR-STATUS     PIC X(10) VALUE SPACES.
           05 TR-REASON     PIC X(100).
       
       LINKAGE SECTION.
       
       01 LK-LAST-TR-ID     PIC X(5).
       
       PROCEDURE DIVISION USING LK-LAST-TR-ID.
       
           OPEN INPUT TRANSACTION-FILE

           MOVE SPACES TO LK-LAST-TR-ID
           
           READ TRANSACTION-FILE
               AT END
                   CLOSE TRANSACTION-FILE
                   GOBACK
           END-READ
           
           PERFORM UNTIL 1 = 2
               READ TRANSACTION-FILE
                   AT END
                       EXIT PERFORM
               END-READ
               MOVE TR-ID (1:5) TO LK-LAST-TR-ID
           END-PERFORM
           
           CLOSE TRANSACTION-FILE
           GOBACK.
