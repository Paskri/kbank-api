       IDENTIFICATION DIVISION.
       PROGRAM-ID. CLIENT-ACCOUNTS.
       AUTHOR PASCAL KRIEG.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.

       FILE-CONTROL.
           SELECT ACCOUNTS-FILE 
               ASSIGN TO "/app/cobol/data/accounts-ind.dat"
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS ACCOUNT-ID
               FILE STATUS IS WS-FS.

       DATA DIVISION.

       FILE SECTION.

       FD ACCOUNTS-FILE.
       01 ACCOUNT-RECORD.
           05 ACCOUNT-ID       PIC 9(4).
           05 ACCOUNT-TYPE     PIC X(8).
           05 OWNER-ID         PIC 9(4).
           05 IBAN             PIC X(27).
           05 BALANCE          PIC 9(10).
           05 ACCOUNT-CUR      PIC X(3).

       WORKING-STORAGE SECTION.

       01 WS-FS               PIC XX.
       01 WS-END              PIC X VALUE 'N'.
           88 EOF             VALUE 'Y'.

       01 WS-TARGET-OWNER     PIC 9(4).
       01 OUT-LINE            PIC X(200).

       PROCEDURE DIVISION.

       MAIN.

           ACCEPT WS-TARGET-OWNER FROM ARGUMENT-VALUE

           OPEN INPUT ACCOUNTS-FILE

           MOVE 0001 TO ACCOUNT-ID

           START ACCOUNTS-FILE
               KEY >= ACCOUNT-ID
               INVALID KEY
                   DISPLAY "NO ACCOUNTS FOUND"
                   STOP RUN
           END-START

           PERFORM UNTIL EOF

               READ ACCOUNTS-FILE NEXT RECORD
                   AT END
                       SET EOF TO TRUE
                   NOT AT END

                       IF OWNER-ID = WS-TARGET-OWNER
                           PERFORM FORMAT-OUTPUT
                       END-IF

               END-READ

           END-PERFORM

           CLOSE ACCOUNTS-FILE

           STOP RUN.

       FORMAT-OUTPUT.

           STRING
               ACCOUNT-ID DELIMITED BY SIZE
               "|"
               ACCOUNT-TYPE DELIMITED BY SIZE
               "|"
               OWNER-ID DELIMITED BY SIZE
               "|"
               IBAN DELIMITED BY SIZE
               "|"
               BALANCE DELIMITED BY SIZE
               "|"
               ACCOUNT-CUR DELIMITED BY SIZE
           INTO OUT-LINE
           END-STRING

           DISPLAY OUT-LINE.
