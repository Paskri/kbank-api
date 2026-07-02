       IDENTIFICATION DIVISION.
       PROGRAM-ID. MIGRATEINDEXED.
       
       ENVIRONMENT DIVISION.
       
       INPUT-OUTPUT SECTION.
       
       FILE-CONTROL.
       
           SELECT INPUT-FILE
               ASSIGN TO "cobol/data/transactions.dat"
               ORGANIZATION IS INDEXED
               ACCESS MODE IS SEQUENTIAL
               RECORD KEY IS TR-IN-ID.
       
           SELECT OUTPUT-FILE
               ASSIGN TO "cobol/data/transactions-copy.dat"
               ORGANIZATION IS LINE SEQUENTIAL.
       
       DATA DIVISION.
       
       FILE SECTION.
       
       FD INPUT-FILE.
       01 INPUT-RECORD.
          05 TR-IN-ID         PIC X(8).
          05 TR-IN-ACCOUNT-ID PIC X(4).
          05 TR-IN-FROM-ID    PIC X(4).
          05 TR-IN-TARGET-ID  PIC X(4).
          05 TR-IN-CLIENT-ID  PIC X(4).
          05 TR-IN-DATE       PIC X(10).
          05 TR-IN-HOUR       PIC X(8).
          05 TR-IN-TYPE       PIC X(10).
          05 TR-IN-AMOUNT     PIC 9(10).
          05 TR-IN-STATUS     PIC X(10).
          05 TR-IN-REASON     PIC X(100).
       
       FD OUTPUT-FILE.
       01 OUTPUT-RECORD.
          05 TR-OUT-ID         PIC X(8).
          05 TR-OUT-ACCOUNT-ID PIC X(4).
          05 TR-OUT-FROM-ID    PIC X(4).
          05 TR-OUT-TARGET-ID  PIC X(4).
          05 TR-OUT-CLIENT-ID  PIC X(4).
          05 TR-OUT-DATE       PIC X(10).
          05 TR-OUT-HOUR       PIC X(8).
          05 TR-OUT-TYPE       PIC X(10).
          05 TR-OUT-AMOUNT     PIC 9(10).
          05 TR-OUT-STATUS     PIC X(10).
          05 TR-OUT-REASON     PIC X(100).
       
       WORKING-STORAGE SECTION.
       
       01 EOF PIC X VALUE "N".
       01 WS-FS PIC XX.
       
       PROCEDURE DIVISION.
       
       MAIN.
       
           OPEN INPUT INPUT-FILE
           OPEN OUTPUT OUTPUT-FILE
       
           PERFORM UNTIL EOF = "Y"
       
               READ INPUT-FILE
                   AT END
                       MOVE "Y" TO EOF
                   NOT AT END
                       MOVE INPUT-RECORD TO OUTPUT-RECORD
                       WRITE OUTPUT-RECORD
               END-READ
       
           END-PERFORM
       
           CLOSE INPUT-FILE OUTPUT-FILE
       
           DISPLAY "COPY COMPLETE"
           STOP RUN.
           