      SUBROUTINE TRD1E(MHH,BHH,KHH,PH,UHV,NGROUP)
C
C     THIS ROUTINE SOLVES TRANSIENT PROBLEM ANALYTICALLY IN CASE
C         OF UNCOUPLED MODAL WITH NO NONLINEAR LOADS
C
      REAL    MI,KI
      INTEGER IZ(1),SYSBUF,IUHV(7),BHH,PH,UHV,FILE
      INTEGER NAME(2)
C
CRLBNB SPR94003 9/94
      COMMON /BLANK / DUMMY(4), NCOL
CRLBNE
      COMMON /PACKX/ IT1,IT2,II,JJ,INCUR
      COMMON /UNPAKX/IT3,III,JJJ,INCUR1
      COMMON /ZZZZZZ/ Z(1)
      COMMON /SYSTEM/ SYSBUF
C
      EQUIVALENCE (IZ(1),Z(1))
C
      DATA NAME/4HTRD1,4HE   /
      DATA EPSI/1.0E-8/
C*********
C     DEFINITION OF VARIABLES
C*********
C     IGROUP   POINTER TO TIME STEP DATA  N1,DELTAT,NO
C     NGROUP   NUMBER OF TIME STEP CHANGES
C     MHH      MODAL MASS FILE
C     KHH      MODAL STIFFNESS FILE
C     BHH      MODAL DAMPING FILE
C     PH       LOAD FILE
C     UHV      DISPLACEMENT,VELOCITY, AND ACCELERATION FILE
C     NMODES   ORDER OF MODAL FORMULATION
C     IMII     POINTER TO MASSES
C     IBII     POINTER TO DAMPING
C     IKII     POINTER TO STIFFNESS
C     IF       POINTER TO F-S
C     IFPR     POINTER TO F PRIMES
C     IG       POINTER TO G-S
C     IGPR
C     IA       POINTER TO A-S
C     IAPR
C     IB       POINTER TO B-S
C     IBPR
C     IUJ      POINTER TO OLD  DISP
C     IUJ1             TO NEW  DISP
C     IUDJ     POINTER TO  OLD VELOCITY VECTOR
C     IUDJ1                NEW VELOCITY VECTOR
C     IPHJ     POINTER TO  OLD LOAD VECTOR
C     IPHJ1                NEW LOAD VECTOR
C     NSTEP    NUMBER OF STEPS AT CURRENT INCREMENT
C     H        CURRENT DELTA T
C     NOUT     OUTPUT INCURMENT
C     EPSI     CASE SELTION TOLERANCE
C
C********    HERE WE GO --GET LOTS OF PAPER
C
      LC = KORSZ(Z)
      LC =LC -NGROUP*3
      IGROUP = LC+1
      IST =-1
      IBUF1 =LC -SYSBUF
      IBUF2 =IBUF1 -SYSBUF
      LC = LC - 2*SYSBUF
      IUHV(1)= MHH
      CALL RDTRL(IUHV)
      NMODES = IUHV(2)
      IT1=1
      IT2=1
      IT3=1
      INCUR=1
      INCUR1=1
      II=1
      JJ=NMODES
      ICRQ = 17*NMODES - LC
      IF(ICRQ.GT.0) GO TO 340
C
C     BRING IN H MATRICES
C
C
C     BRING IN  MHH
      FILE =MHH
      IMII =0
      KK=IMII
      ASSIGN 10 TO IRETN
      GO TO 280
C
C     BRING IN BHH
   10 DO 11 J=1,NMODES
      IF(Z(J) .EQ. 0.0) GO TO 350
   11 CONTINUE
      FILE = BHH
      IBII= IMII+ NMODES
      KK = IBII
      ASSIGN 20 TO IRETN
      GO TO 280
C
C     BRING IN KHH
   20 FILE =KHH
      IKII = IBII +NMODES
      KK= IKII
      ASSIGN 30 TO IRETN
      GO TO 280
C
C     ASSIGN ADDITIONAL POINTERS
C
   30 III=1
      JJJ=NMODES
      IF = IKII + NMODES
      IG = IF   + NMODES
      IA = IG   + NMODES
      IB = IA   + NMODES
      IFPR=IB   + NMODES
      IGPR=IFPR + NMODES
      IAPR=IGPR + NMODES
      IBPR=IAPR + NMODES
      IUJ =IBPR + NMODES
      IUJ1=IUJ  + NMODES
      IUDJ=IUJ1 + NMODES
      IUDJ1=IUDJ+ NMODES
      IPHJ =IUDJ1+NMODES
      IPHJ1=IPHJ +NMODES
CRLBNB SPR94003 9/94
      IF (NCOL .LE. 2) GO TO 37
C
C     RETRIEVE OLD DISPLACEMENT AND VELOCITY
C     FROM A PREVIOUSLY CHECKPOINTED RUN
C
      CALL GOPEN (UHV, IZ(IBUF1), 0)
      I = 3*(NCOL - 1)
      CALL SKPREC (UHV, I)
C
C     RETRIEVE OLD DISPLACEMENT
C
      CALL UNPACK (*31, UHV, Z(IUJ1+1))
      GO TO 33
   31 DO 32 I = 1, NMODES
      K = IUJ1 + I
      Z(K) = 0.0
   32 CONTINUE
C
C     RETRIEVE OLD VELOCITY
C
   33 CALL UNPACK (*34, UHV, Z(IUDJ1+1))
      GO TO 36
   34 DO 35 I = 1, NMODES
      K = IUDJ1 + I
      Z(K) = 0.0
   35 CONTINUE
   36 CALL CLOSE (UHV, 1)
CRLBNE
C
C     READY UHV
C
CRLBR SPR94003 9/94      CALL GOPEN(UHV,IZ(IBUF1),1)
   37 CALL GOPEN(UHV,IZ(IBUF1),1)
      CALL MAKMCB(IUHV,UHV,NMODES,2,1)
C
C     READY LOADS
C
      CALL GOPEN(PH,IZ(IBUF2),0)
      CALL UNPACK(*40,PH,Z(IPHJ1+1))
      GO TO 60
C
C     ZERO LOAD
C
   40 DO 50 I=1,NMODES
      K = IPHJ1+I
      Z(K) = 0.0
   50 CONTINUE
CRLBNB SPR94003 9/94
   60 IF (NCOL .GT. 2) GO TO 75
CRLBNE
C
C     ZERO INITIAL DISPLACEMENT AND VELOCITY
C
CRLBR SPR 94003 9/94   60 DO 70 I=1,NMODES
      DO 70 I=1,NMODES      
      K = IUJ1+I
      Z(K) = 0.0
      K = IUDJ1+I
      Z(K) = 0.0
   70 CONTINUE
C
C     BEGIN LOOP ON EACH DIFFERENT TIME STEP
C
CRLBR SPR 94003 9/94      I = 1
   75 I = 1
   80 NSTEP = IZ(IGROUP)
      IF(I .EQ. 1) NSTEP = NSTEP+1
      H     =  Z(IGROUP+1)
      NOUT = IZ(IGROUP+2)
      IGROUP = IGROUP +3
      JK = 1
      IF(I .EQ. 1) GO TO 170
C
C     COMPUTE F-S ,G-S,A-S,B-S
C
   90 DO 140 J=1,NMODES
      K= IMII+J
      MI= Z(K)
      IF(MI .EQ. 0.0) GO TO 350
      K= IBII+J
      BI= Z(K)
      K = IKII+J
      KI= Z(K)
      WOSQ =KI/MI
      BETA = BI/(2.0*MI)
      BETASQ =BETA*BETA
      WSQ  = ABS(WOSQ - BETASQ)
      W = SQRT(WSQ)
      IF(SQRT(WSQ + BETASQ)*H .LT. 1.E-6) GO TO 100
      T1 = ( WOSQ-BETASQ ) / WOSQ
      IF( T1 .GT. EPSI ) GO TO 110
      IF( T1 .LT. -EPSI) GO TO 130
C
C     CASE  3  CRITICALLY DAMPED
C
      BH = BETA*H
      EXPBH = EXP(-BH)
      T1 = H*KI
      K = IF+J
C
C     COMPUTE F
C
      Z(K) = EXPBH*(1.0 +BH)
C
C     COMPUTE  G
C
      K = IG +J
      Z(K)= H*EXPBH
C
C     COMPUTE A
C
      K = IA +J
      Z(K) = (2.0/BETA - EXPBH/BETA*(2.0 +2.0*BH + BH*BH))/ T1
C
C     COMPUTE B
C
      K=IB +J
      Z(K) = (-2.0 +BH+EXPBH*(2.0+BH))/(BH*KI)
C
C     COMPUTE  F PRIME
C
      K= IFPR+J
      Z(K) = -BETASQ*H*EXPBH
C
C     COMPUTE  G PRIME
C
      K = IGPR+J
      Z(K)= EXPBH*(1.0- BH)
C
C     COMPUTE A PRIME
C
      K = IAPR +J
      Z(K) = (EXPBH*(1.0 + BH + BH*BH)- 1.0)/T1
C
C     COMPUTE  B PRIME
C
      K = IBPR +J
      Z(K) = (1.0 -EXPBH*(BH +1.0))/T1
      GO TO 140
C
C     CASE  4   W0 = BETA =0.0
C
  100 K=IF+J
      Z(K)=1.0
      K= IG+J
      Z(K)=H
      K= IA+J
      Z(K)= H*H/(3.0*MI)
      K= IB+J
      Z(K)= H*H/(6.0*MI)
      K= IFPR+J
      Z(K)=0.0
      K= IGPR+J
      Z(K)=1.0
      T1 = H/(2.0*MI)
      K = IAPR+J
      Z(K)= T1
      K=  IBPR+J
      Z(K)= T1
      GO TO 140
C
C     CASE 1 --UNDERDAMPED
C
  110 WH = W*H
      EXPBH = EXP(-BETA*H)
      SINWH = SIN(WH)
      COSWH = COS(WH)
C
C     COMPUTE F
C
  120 K= IF +J
      Z(K)= EXPBH*(COSWH +BETA/W *SINWH)
C
C     COMPUTE G
C
      K = IG +J
      Z(K) = EXPBH/W*SINWH
C
C     COMPUTE A
C
      K= IA+J
      T1 =(WSQ -BETASQ)/WOSQ
      T2 = 2.0*W*BETA/WOSQ
      T3 = WH*KI
      Z(K)= (EXPBH*((T1-BETA*H)*SINWH-(T2+WH)*COSWH)+T2)/T3
C
C     COMPUTE  B
C
      K =IB +J
      Z(K) = (EXPBH*(-T1*SINWH + T2*COSWH)+WH- T2)/T3
C
C     COMPUTE  FPRIME
C
      K = IFPR+J
      Z(K) = -WOSQ/W*EXPBH*SINWH
C
C     COMPUTE G PRIME
C
      K =IGPR +J
      Z(K) = EXPBH*(COSWH -BETA/W *SINWH)
C
C     COMPUTE A PRIME
C
      K = IAPR +J
      Z(K) =(EXPBH*((BETA +WOSQ*H)*SINWH +W*COSWH)- W)/T3
C
C     COMPUTE B PRIME
C
      K =IBPR +J
      Z(K) = (-EXPBH*(BETA*SINWH +W*COSWH) + W)/T3
      GO TO 140
C
C     CASE  3    W0 - BETASQ L -E
C
  130 WH =W*H
      EXPBH= EXP(-BETA*H)
      SINWH =   SINH(WH)
      COSWH =   COSH(WH)
      BETASQ = -BETASQ
      GO TO 120
  140 CONTINUE
C
C     BEGIN LOOP ON INCREMENTS
C
C
C     COMPUTE  NEW DISPLACEMENTS
C
  150 K = IUJ1
      KK=IUDJ1
      DO 160 L=1,NMODES
      K=K+1
      KK =KK+1
      Z(K)=0.0
      Z(KK)=0.0
      KKK = IF+L
      KD =  IUJ +L
      Z(K) =Z(KKK)*Z(KD) +Z(K)
      KKK = IFPR +L
      Z(KK) = Z(KKK)*Z(KD) +Z(KK)
      KD= IUDJ+L
      KKK = IG +L
      Z(K) = Z(KKK)*Z(KD) +Z(K)
      KKK = IGPR +L
      Z(KK) = Z(KKK)*Z(KD) +Z(KK)
      KD = IPHJ +L
      KKK = IA +L
      Z(K) = Z(KKK)*Z(KD) +Z(K)
      KKK  = IAPR +L
      Z(KK)= Z(KKK)*Z(KD) + Z(KK)
      KD = IPHJ1+L
      KKK=  IB +L
      Z(K) = Z(KKK)*Z(KD) +Z(K)
      KKK  = IBPR +L
      Z(KK) = Z(KKK)*Z(KD) + Z(KK)
  160 CONTINUE
      IF(JK .EQ. NSTEP) GO TO 200
      IF( JK .NE. 1 .AND. MOD(JK+IST,NOUT) .NE. 0) GO TO 180
C
C     TIME TO OUTPUT--YOU LUCKY FELLOW
C
  170 ASSIGN 190 TO IRETN
      GO TO 220
  180 ASSIGN 190 TO IRETN
      GO TO 240
  190 JK = JK+1
      IF(JK .EQ. 2 .AND. I .EQ. 1) GO TO 90
      IF(JK .LE. NSTEP) GO TO 150
  200 ASSIGN 210 TO IRETN
      GO TO 220
  210 I =I+1
      IST = 0
      IF( I .LE. NGROUP) GO TO 80
      CALL CLOSE(PH,1)
      CALL CLOSE(UHV,1)
      CALL WRTTRL(IUHV)
      RETURN
C
C     INTERNAL SUBROUTINE FOR OUTPUT AND VELOCITY COMPUTE
C
  220 CALL PACK(Z(IUJ1+1),UHV,IUHV)
      CALL PACK(Z(IUDJ1+1),UHV,IUHV)
C
C     COMPUTE  ACCELERATIONS
C
      DO 230 L=1,NMODES
      K= IUDJ+L
      KK=IPHJ1+L
      KKK = IMII+L
      KD = IBII+L
      KD1= IUDJ1+L
      KD2= IUJ1 +L
      KD3 = IKII+L
      Z(K) = Z(KK)/Z(KKK)-Z(KD)*Z(KD1)/Z(KKK)-Z(KD3)*Z(KD2)/Z(KKK)
  230 CONTINUE
      CALL PACK(Z(IUDJ+1),UHV,IUHV)
C
C     SWITCH POINTS TO STUFF
C
  240 KD= IUJ
      IUJ = IUJ1
      IUJ1=KD
      KD= IUDJ
      IUDJ =IUDJ1
      IUDJ1=KD
      KD = IPHJ
      IPHJ =IPHJ1
      IPHJ1= KD
C
C     BRING IN NEXT LOAD VECTOR
C
      CALL UNPACK(*260,PH,Z(IPHJ1+1))
  250 GO TO IRETN,(190,210)
  260 DO 270 KD=1,NMODES
      K = IPHJ1 +KD
      Z(K) =0.0
  270 CONTINUE
      GO TO 250
C
C     INTERNAL SUBROUTINE TO BRING  IN H MATRICES
C
  280 CALL OPEN(*302,FILE,IZ(IBUF1),0)
      CALL SKPREC(FILE,1)
      DO 300 KD=1,NMODES
      III= KD
      JJJ= KD
      KD1= KK+KD
      CALL UNPACK(*290,FILE,Z(KD1))
      GO TO 300
  290 Z(KD1)= 0.0
  300 CONTINUE
      CALL CLOSE(FILE,1)
  301 GO TO IRETN,(10,20,30)
C
C      ZERO CORE FOR PURGED FILES
C
  302 DO 303 KD = 1,NMODES
      KD1 = KK + KD
      Z(KD1) = 0.0
  303 CONTINUE
      GO TO 301
C
C     ERROR MESAGES
C
  320 CALL MESAGE(IP1,FILE,NAME)
      RETURN
  340 IP1 = -8
      FILE = ICRQ
      GO TO 320
  350 IP1 = -43
      FILE = J
      GO TO 320
      END