10 INPUT "What is your name: "; U$
20 PRINT "Hello "; U$
30 REM Test
40 INPUT "How many stars do you want: "; N
50 S$ = ""
60 FOR I = 1 TO N
70 S$ = S$ + "*"
80 NEXT I
90 PRINT S$
100 REM
110 INPUT "Do you want more stars? "; A$
120 IF LEN(A$) = 0 THEN GOTO 110
130 A$ = LEFT$(A$, 1)
140 IF (A$ = "Y") OR (A$ = "y") THEN GOTO 40
150 PRINT "Goodbye ";
160 FOR I = 1 TO 200
170 PRINT U$; " ";
180 NEXT I
190 PRINT
