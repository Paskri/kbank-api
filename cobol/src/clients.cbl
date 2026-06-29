       IDENTIFICATION DIVISION.
       PROGRAM-ID. CLIENTS.
       AUTHOR PASCAL KRIEG.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT CLIENT-FILE ASSIGN TO "cobol/data/clients.dat"
           ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.

       FD CLIENT-FILE.
       01 CLIENT-REC.
           05 CLIENT-ID     PIC 9(4).
           05 CLIENT-NAME   PIC X(20).
           05 CLIENT-FIRST  PIC X(20).

       WORKING-STORAGE SECTION.
       01 EOF PIC X VALUE "N".

       PROCEDURE DIVISION.

           OPEN INPUT CLIENT-FILE

           PERFORM UNTIL EOF = "Y"
               READ CLIENT-FILE
                   AT END
                      MOVE "Y" TO EOF
                   NOT AT END
                      DISPLAY CLIENT-ID "|" CLIENT-NAME "|" CLIENT-FIRST
               END-READ
           END-PERFORM

           CLOSE CLIENT-FILE

           STOP RUN.
