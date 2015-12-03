      SUBROUTINE GETBLK (IOLD,INEW)
C
C     FINDS A FREE BLOCK INEW.  IF IOLD IS NOT ZERO IOLD POINTER WILL
C     BE SET TO INEW.
C
      EXTERNAL        LSHIFT,RSHIFT,ANDF,ORF
      LOGICAL         DITUP,NXTUP,NXTRST
      INTEGER         BUF,DIT,DITPBN,DITLBN,DITSIZ,DITNSB,DITBL,ORF,
     1                BLKSIZ,DIRSIZ,SUPSIZ,FILSIZ,AVBLKS,ANDF,RSHIFT,
     2                FILNUM,TPFREE,BTFREE,FILIND,FILSUP,NMSBR(2)
      COMMON /MACHIN/ MACH,IHALF,JHALF
      COMMON /ZZZZZZ/ BUF(1)
      COMMON /SOF   / DIT,DITPBN,DITLBN,DITSIZ,DITNSB,DITBL,
     1                IODUM(8),MDIDUM(4),
     2                NXT,NXTPBN,NXTLBN,NXTTSZ,NXTFSZ(10),NXTCUR,
     3                DITUP,MDIUP,NXTUP,NXTRST
      COMMON /SYS   / BLKSIZ,DIRSIZ,SUPSIZ,AVBLKS
      COMMON /SOFCOM/ NFILES,FILNAM(10),FILSIZ(10)
      COMMON /SYSTEM/ NBUFF
      DATA   IRD    , IWRT / 1, 2    /
      DATA   INDSBR / 11   /,  NMSBR / 4HGETB,4HLK  /
C
C     CHECK IF THE SUPERBLOCK NXTCUR HAS A FREE BLOCK.
C
      CALL CHKOPN (NMSBR(1))
      LMASK = LSHIFT(JHALF,IHALF)
    5 IF (NXTCUR .EQ. NXTLBN) GO TO 40
C
C     THE SUPERBLOCK NXTCUR IS NOT IN CORE.
C
      IF (NXTLBN .EQ. 0) GO TO 10
C
C     THE IN CORE BUFFER SHARED BY THE DIT AND THE ARRAY NXT IS NOW
C     OCCUPIED BY A BLOCK OF NXT.
C
      IF (.NOT.NXTUP) GO TO 20
C
C     THE BLOCK OF THE ARRAY NXT WHICH IS NOW IN CORE HAS BEEN UPDATED,
C     MUST THEREFORE WRITE IT OUT BEFORE READING IN A NEW BLOCK.
C
      CALL SOFIO (IWRT,NXTPBN,BUF(NXT-2))
      NXTUP = .FALSE.
      GO TO 20
   10 IF (DITPBN .EQ. 0) GO TO 20
C
C     THE IN CORE BUFFER SHARED BY THE DIT AND THE ARRAY NXT IS NOW
C     OCCUPIED BY A BLOCK OF DIT.
C
      IF (.NOT.DITUP) GO TO 15
C
C     THE DIT BLOCK WHICH IS NOW IN CORE HAS BEEN UPDATED, MUST
C     THEREFORE WRITE IT OUT BEFORE READING IN A NEW BLOCK.
C
      CALL SOFIO (IWRT,DITPBN,BUF(DIT-2))
      DITUP  = .FALSE.
   15 DITPBN = 0
      DITLBN = 0
C
C     READ INTO CORE THE DESIRED BLOCK OF THE ARRAY NXT.
C
   20 NXTLBN = NXTCUR
      NXTPBN = 0
      LEFT   = NXTLBN
      DO 25 I = 1,NFILES
      IF (LEFT .GT. NXTFSZ(I)) GO TO 23
      FILNUM = I
      GO TO 30
   23 NXTPBN = NXTPBN + FILSIZ(I)
      LEFT   = LEFT - NXTFSZ(I)
   25 CONTINUE
      GO TO 510
   30 NXTPBN = NXTPBN + (LEFT-1)*SUPSIZ + 2
      CALL SOFIO (IRD,NXTPBN,BUF(NXT-2))
C
C     CHECK THE FREE LIST OF SUPERBLOCK NXTCUR.
C
   40 TPFREE = RSHIFT(BUF(NXT+1),IHALF)
      IF (TPFREE .GT. 0) GO TO 180
C
C     THE SUPERBLOCK NXTCUR DOES NOT HAVE ANY FREE BLOCKS.
C
      IF (NXTCUR .EQ. NXTTSZ) GO TO 50
      NXTCUR = NXTCUR + 1
      GO TO 5
C
C     NXTCUR IS THE LAST SUPERBLOCK.
C
   50 IF (NXTRST) GO TO 60
      NXTCUR = 1
      NXTRST = .TRUE.
      GO TO 5
C
C     MUST START A BRAND NEW SUPERBLOCK.
C
   60 NXTRST = .FALSE.
      IF (NXTUP) CALL SOFIO (IWRT,NXTPBN,BUF(NXT-2))
      NXTUP  = .FALSE.
   70 NXTCUR = NXTCUR + 1
      LEFT   = NXTCUR
      DO 80 I = 1,NFILES
      IF (LEFT .GT. NXTFSZ(I)) GO TO 75
      FILNUM = I
      GO TO 85
   75 LEFT   = LEFT-NXTFSZ(I)
   80 CONTINUE
      NXTCUR = NXTCUR - 1
      GO TO 500
   85 LAST   = NBUFF - 4
      DO 86 I = 1,LAST
      BUF(NXT+I) = 0
   86 CONTINUE
      IF (LEFT .EQ. 1) GO TO 110
C
C     NXTCUR IS NOT THE FIRST SUPERBLOCK ON FILE FILNUM.
C
      NXTPBN = NXTPBN + SUPSIZ
      IF (LEFT .NE. NXTFSZ(FILNUM)) GO TO 120
C
C     NXTCUR IS THE LAST BLOCK ON FILE FILNUM.
C
      LSTSIZ = MOD(FILSIZ(FILNUM)-2,SUPSIZ) + 1
      IF (LSTSIZ .GT. 1) GO TO 90
C
C     THE SIZE OF THE LAST BLOCK ON FILE FILNUM IS EQUAL TO 1.
C     THERE ARE THEREFORE NO FREE BLOCKS AVAILABLE ON SUPERBLOCK NXTCUR.
C     SET TPFREE AND BTFREE OF NXTCUR EQUAL TO ZERO.
C
      BUF(NXT+1) = 0
      AVBLKS = AVBLKS - 1
      CALL SOFIO (IWRT,NXTPBN,BUF(NXT-2))
      GO TO 70
C
C     THE SIZE OF SUPERBLOCK NXTCUR IS LARGER THAN 1.
C
   90 IF (LSTSIZ .GT. 2) GO TO 100
C
C     THE SIZE OF SUPERBLOCK NXTCUR IS EQUAL TO 2.  THERE IS THEREFORE
C     ONLY ONE FREE BLOCK IN NXTCUR.  SET TPFREE AND BTFREE TO ZERO.
C
      BUF(NXT+1) = 0
      GO TO 170
C
C     THE SIZE OF SUPERBLOCK NXTCUR IS LARGER THAN 2.
C
  100 BTFREE = NXTPBN + LSTSIZ - 1
      GO TO 130
C
C     NXTCUR IS THE FIRST SUPERBLOCK ON FILE FILNUM.
C
  110 LSTSIZ = MOD(FILSIZ(FILNUM-1)-2,SUPSIZ) + 1
      NXTPBN = NXTPBN + LSTSIZ + 1
      AVBLKS = AVBLKS - 1
      IF (FILSIZ(FILNUM) .GE. SUPSIZ+1) GO TO 120
      BTFREE = NXTPBN + FILSIZ(FILNUM) - 2
      GO TO 130
  120 BTFREE = NXTPBN + SUPSIZ - 1
C
C     INITIALIZE THE NEW SUPERBLOCK.
C
  130 TPFREE = NXTPBN + 2
C
C     PUT THE VALUES OF BTFREE AND TPFREE IN THE FIRST WORD OF THE ARRAY
C     NXT BELONGING TO SUPERBLOCK NXTCUR.
C
      BUF(NXT+1) = BTFREE
      BUF(NXT+1) = ORF(BUF(NXT+1),LSHIFT(TPFREE,IHALF))
      IF (MOD(BTFREE,2) .EQ. 1) GO TO 140
C
C     BTFREE IS AN EVEN INTEGER.
C
      MAX = (BTFREE-NXTPBN+2)/2
      BUF(NXT+MAX+1) = 0
      GO TO 150
C
C     BTFREE IS AN ODD INTEGER.
C
  140 MAX = (BTFREE-NXTPBN+1)/2
      BUF(NXT+MAX+1) = LSHIFT(BTFREE,IHALF)
C
C     SET UP THE THREAD THROUGH THE BLOCKS OF SUPERBLOCK NXTCUR.
C
  150 IF (MAX.LT.3) GO TO 170
      DO 160 I = 3,MAX
      BUF(NXT+I) = 2*I + NXTPBN - 2
      BUF(NXT+I) = ORF(BUF(NXT+I),LSHIFT(2*I+NXTPBN-3,IHALF))
  160 CONTINUE
C
C     SETUP VARIABLES RELATED TO THE SUPERBLOCK NXTCUR.
C
  170 BUF(NXT+2) = 0
      INEW   = NXTPBN + 1
      AVBLKS = AVBLKS - 2
      NXTLBN = NXTCUR
      NXTTSZ = NXTCUR
      GO TO 230
C
C     SUPERBLOCK NXTCUR DOES HAVE A FREE BLOCK.
C
  180 INEW   = TPFREE
      AVBLKS = AVBLKS - 1
C
C     COMPUTE THE INDEX OF TPFREE ENTRY IN THE BLOCK OF ARRAY NXT
C     BELONGING TO SUPERBLOCK NXTCUR.
C
      FILIND = TPFREE
      DO 185 I = 1,NFILES
      IF (FILIND .LE. FILSIZ(I)) GO TO 187
      FILIND = FILIND - FILSIZ(I)
  185 CONTINUE
  187 FILSUP = (FILIND-1)/SUPSIZ
      IF (FILIND-1 .EQ. FILSUP*SUPSIZ) GO TO 190
      FILSUP = FILSUP + 1
  190 INDEX  = (FILIND-(FILSUP-1)*SUPSIZ)/2 + 1
      IF (MOD(TPFREE,2) .EQ. 1) GO TO 200
C
C     TPFREE IS AN EVEN INTEGER.  THE ENTRY FOR TPFREE IS THEREFORE
C     IN BITS (IHALF+1) TO (2*IHALF-1) OF THE WORD.  SAVE TPFREE ENTRY
C     IN NXTBLK AND THEN SET IT TO ZERO.
C
      NXTBLK = RSHIFT(BUF(NXT+INDEX),IHALF)
      BUF(NXT+INDEX) = ANDF(BUF(NXT+INDEX),JHALF)
      GO TO 210
C
C     TPFREE IS AN ODD INTEGER.  THE ENTRY FOR TPFREE IS THEREFORE
C     IN BITS 0 TO IHALF OF THE WORD.  SAVE TPFREE ENTRY IN NXTBLK
C     AND THEN SET IT TO ZERO.
C
  200 NXTBLK = ANDF(BUF(NXT+INDEX),JHALF)
      BUF(NXT+INDEX) = ANDF(BUF(NXT+INDEX),LMASK)
  210 BTFREE = ANDF(BUF(NXT+1),JHALF)
      IF (TPFREE .EQ. BTFREE) GO TO 220
C
C     SET TPFREE TO NXTBLK.
C
      BUF(NXT+1) = ORF(ANDF(BUF(NXT+1),JHALF),LSHIFT(NXTBLK,IHALF))
      GO TO 230
C
C     SET TPFREE AND BTFREE TO ZERO.
C
  220 BUF(NXT+1) = 0
  230 IF (IOLD .EQ. 0) GO TO 250
C
C     WANT TO SET IOLD POINTER TO INEW.
C
      NXTUP =.TRUE.
      CALL FNXT (IOLD,IND)
      IF (MOD(IOLD,2) .EQ. 1) GO TO 240
C
C     IOLD IS AN EVEN INTEGER
C
      BUF(IND) = ORF(ANDF(BUF(IND),JHALF),LSHIFT(INEW,IHALF))
      GO TO 250
C
C     IOLD IS AN ODD INTEGER
C
  240 BUF(IND) = ORF(ANDF(BUF(IND),LMASK),INEW)
  250 NXTUP = .TRUE.
      RETURN
C
C     ERROR MESSAGES.
C
  500 INEW = -1
      RETURN
  510 CALL ERRMKN (INDSBR,4)
      RETURN
      END
