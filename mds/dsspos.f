      SUBROUTINE DSSPOS( FILE, KCBLK, KCLR, KCBP )
C
C DSSPOS REPOSITIONS THE "FILE" TO BLOCK "KCBLK" WITH THE CURRENT
C LOGICAL RECORD POINTER SET TO "KCLR" AND THE CURRENT BUFFER
C POINTER SET TO "KCBP"
C
      INCLUDE 'DSIOF.COM'
      INCLUDE 'XNSTRN.COM'
      INTEGER    FILE
      NAME  = FILE
      CALL DSGEFL
      ICBLK  = FCB( 4, IFILEX )
      IF ( ICBLK .EQ. KCBLK ) GO TO 10
      NBLOCK = KCBLK
      CALL DBMMGR( 6 )
10    CONTINUE
      INDCLR = KCLR + INDBAS - 1
      INDCBP = KCBP + INDBAS - 1
      CALL DSSDCB
      RETURN
      END
