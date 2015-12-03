      SUBROUTINE MODACC
C
C     THIS IS THE MODULE MODACC
C
C     DMAP CALL
C
C     MODACC  CASECC,TOL,UDV1T,PPT,PDT,PST/TOL1,UDV3T,PP3,PDT3,PST3/
C             C,N,TRAN $
C
C     THE PURPOSE OF THIS MODULE IS TO REDUCE THE COLUMN LENCTHS OF
C     UDV1T,PPT,PDT,PST  TO THE  LENGTH SPECIFIED BY OFREQ IN CASECC.
C     THE CURRENT LIST OF TIMES IS ON  TOL
C
      INTEGER CASECC, TOL,UDV1T,PPT,PDT,PST,TOL1,UDV3T,PP3,PDT3,PST3
      COMMON /BLANK / IOP(2)
      COMMON /MODAC3/ NFO,NFN,NZ,ID
      COMMON /ZZZZZZ/ IZ(1)
      DATA    CASECC, TOL,UDV1T,PPT,PDT,PST,TOL1,UDV3T,PP3,PDT3,PST3 /
     1        101   , 102,103  ,104,105,106,201 ,202  ,203,204 ,205  /
      DATA    ITRAN / 4HTRAN/  ,ICEIGN /4HCEIG /
      DATA    IREIG / 4HREIG/
      DATA    ISTAT / 4HSTAT/
C
      ID = 1
      IF (IOP(1) .EQ. ICEIGN) ID = 2
      IF (IOP(1) .EQ.  ITRAN) ID = 3
      IF (IOP(1) .EQ.  IREIG) ID = 4
      IF (IOP(1) .EQ.  ISTAT) ID = 5
C
C     FOR EIGENVALUES STOP LIST AT NUMBER OF VECTORS
C
      NFO = 0
      IZ(1) = UDV1T
      CALL RDTRL(IZ)
      J   = 2
      NFO = 2 * IZ(J)
      NZ  = KORSZ(IZ(1))
C
C     BUILD LIST OF NEW TIMES, KEEP/REMOVE LIST
C
      CALL MODAC1 (CASECC,TOL,TOL1,PP3,PPT)
C
C     COPY DISPLACEMENTS
C
      ID1 = 1
      IF (ID .EQ. 3) ID1 = 3
      CALL MODAC2 (ID1,UDV1T,UDV3T)
      IF (ID.EQ.2 .OR. ID.EQ.4) RETURN
C
C     COPY P LOAD S  (+ HEAD STUFF FOR NOW)
C
      CALL MODAC2 (-1,PPT,PP3)
C
C     COPY D LOADS
C
      CALL MODAC2 (1,PDT,PDT3)
C
C     COPY S LOADS
C
      CALL MODAC2 (1,PST,PST3)
      RETURN
      END
