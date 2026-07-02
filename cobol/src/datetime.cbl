       IDENTIFICATION DIVISION.
       PROGRAM-ID. DATETIME.
       
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       
       01 WS-DT.
          05 WS-DATE.
             10 WS-YEAR       PIC X(4).
             10 WS-MONTH      PIC X(2).
             10 WS-DAY        PIC X(2).
          05 WS-TIME.
             10 WS-HOUR       PIC X(2).
             10 WS-MIN        PIC X(2).
             10 WS-SEC        PIC X(2).
          05 WS-REST           PIC X(10).
       
       LINKAGE SECTION.
       
       01 LK-DATE-FORMATTED   PIC X(10).
       01 LK-TIME-FORMATTED   PIC X(8).
       
       PROCEDURE DIVISION USING LK-DATE-FORMATTED LK-TIME-FORMATTED.
       
           MOVE FUNCTION CURRENT-DATE TO WS-DT
       
           *> DATE = YYYY-MM-DD
           STRING
               WS-YEAR DELIMITED BY SIZE
               "-"
               WS-MONTH DELIMITED BY SIZE
               "-"
               WS-DAY DELIMITED BY SIZE
               INTO LK-DATE-FORMATTED
           END-STRING
       
           *> TIME = HH:MM:SS
           STRING
               WS-HOUR DELIMITED BY SIZE
               ":"
               WS-MIN DELIMITED BY SIZE
               ":"
               WS-SEC DELIMITED BY SIZE
               INTO LK-TIME-FORMATTED
           END-STRING

           GOBACK.
           