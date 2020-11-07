C$TEST QBLG
C TO RUN AS A MAIN PROGRAM REMOVE NEXT LINE
      SUBROUTINE QBLG
C***********************************************************************
C
C  TEST OF THE PORT PROGRAM QUAD
C
C***********************************************************************
C   BLUE'S QUADRATURE TESTER - SINGLE-PRECISION- OBTAINED 6/16/77.
C
C THIS PACKAGE CONSISTS OF THREE TEST SUBROUTINES AND A MAIN PROGRAM
C
C    A. TEST ON KAHANER'S 21 TEST INTEGRALS PUBLISHED IN MATHEMATICAL
C       SOFTWARE, J. R. RICE, ED., ACADEMIC PRESS 1971.  MAIN PROGRAM
C       AND FUNCTION SUBPROGRAM.
C    B. VARY PARAMETER ALPHA AND ACCURACY EPSILON.  MAIN PROGRAM, TWO
C       FUNCTION SUBPROGRAMS, AND ONE SUBROUTINE.
C    C. VARY NOISE IN FUNCTION.  MAIN PROGRAM AND FUNCTION SUBPROGRAM.
C
C
      CALL ENTER(1)
      CALL TEST1
      CALL TEST2
      CALL TEST3
      STOP
      END
      SUBROUTINE TEST1
C
C        FIRST OF THREE TEST PACKAGES
C        TEST QUAD ON KAHANER'S 21 FUNCTIONS
C
      DIMENSION A(22),B(22),ANS(22)
      REAL A,B,ANS,EPS,F,ANSWER,ERREST
      EXTERNAL F
      COMMON/WHICH/N,JCALL
C
      DATA A/0.E0,0.E0,0.E0,-1.E0,-1.E0,0.E0,0.E0,0.E0,0.E0,0.E0,0.E0,
     *     0.E0,0.1E0,0.E0,0.E0,0.E0,.01E0,0.E0,0.E0,-1.E0,0.E0,0.E0/
      DATA B/13*1.E0,3*10.E0,1.E0,3.1415927E0,4*1.E0/
      DATA ANS/1.7182818284E0,0.7E0,.6666666667E0,.4794282267E0,
     *  1.5822329637E0,
     *  0.4E0,2.E0,.8669729873E0,1.154700669E0,.6931471806E0,
     *  .3798854930E0,.7775046341E0,.009098645256E0,.5000002112E0,1.E0,
     *  .4993638029E0,.1121395696E0,.8386763234E0,-1.E0,1.564396443E0,
     *  2*0.2108027354E0/
C
C   SET THE OUTPUT UNIT TO IWRITE
C
       IWRITE = I1MACH(2)
C
      DO 1000 J=3,6,3
         EPS=10.**(-J)
         WRITE(IWRITE,1) EPS
    1    FORMAT(1H1,10X,26HTEST OF QUAD ON KAHANER 21//
     *    10X,17HATTEMPED ACCURACY,1PE12.3)
    2    FORMAT(///12X,1HN,6X,4HTRUE,11X,4HCALC,
     *    9X,5HERROR,7X,7HEST ERR,4X,15HJCALL     KWARN//)
         WRITE(IWRITE,2)
          DO 900 N=1,22
             JCALL=0
             CALL QUAD(F,A(N),B(N),EPS,ANSWER,ERREST)
            CALL ERROFF
            KWARN=0
            IF (ERREST .GT. EPS) KWARN=1
             ERR=ANS(N)-ANSWER
  900       WRITE(IWRITE,901) N,ANS(N),ANSWER,ERR,ERREST,JCALL,KWARN
  901       FORMAT(10X,I3, 2F15.10,1P2E12.3,I6,I10)
 1000 CONTINUE
      RETURN
       END
      REAL FUNCTION F(X)
      COMMON/WHICH/N,JCALL
      REAL X,SECH,PI,Y
      DATA PI/3.14159E0/
C
      SECH(Y)=2.*EXP(-ABS(Y))/(1.+EXP(-2.*ABS(Y)))
C
      JCALL=JCALL+1
       GO TO (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21
     *  ,22),N
C
    1 F=EXP(X)
      RETURN
    2 F=0.
      IF(X.GE.0.3E0) F=1.
      RETURN
    3 F=SQRT(X)
      RETURN
    4 F=0.46E0*(EXP(X)+EXP(-X))-COS(X)
      RETURN
    5 F=1./(X**4+X**2+0.9E0)
      RETURN
    6 F=X*SQRT(X)
      RETURN
    7 F=0.
      IF(X.GT.0.E0) F=1./SQRT(X)
      RETURN
    8 F=1./(1.+X**4)
      RETURN
    9 F=2./(2.+SIN( 10.*PI*X))
      RETURN
   10 F=1./(1.+X)
      RETURN
   11 F=1./(1.+EXP(X))
      RETURN
   12 F=1.
      IF(X.GT.0.E0) F=X/(EXP(X)-1.E0)
      RETURN
   13 F=100.
      IF(X.GT.0.E0) F=SIN(100.*PI*X)/(PI*X)
      RETURN
   14 F=SQRT(50.)*EXP(-50.*PI*X**2)
      RETURN
   15 F=25.*EXP(-25.*X)
      RETURN
   16 F=50./(PI*(2500.*X**2+1.))
      RETURN
   17 F=(SIN(50.*  PI   *X))**2/(50.*(  PI   *X)**2)
      RETURN
   18 F=COS( COS(X)+3.*SIN(X)+2.*COS(2.*X)+SIN(2.*X)+3.*COS(3.*X)
     *   +2.*SIN(2.*X))
      RETURN
   19 F=0.
      IF(X.GT.0.E0) F=ALOG(X)
      RETURN
   20 F=1./(X**2+1.005E0)
      RETURN
   21 F=(SECH(  10.*(X-0.2E0)))**2
     * +(SECH( 100.*(X-0.4E0)))**4
     * +(SECH(1000.*(X-0.6E0)))**6
      RETURN
   22 F=(SECH(  10.*(X-0.2E0)))**2
     * +(SECH( 100.*(X-0.4E0)))**4
     * +(SECH(1000.*(X-.61E0)))**6
      RETURN
      END
      SUBROUTINE TEST2
C
C        SECOND TEST PACKAGE FOR QUAD
C
C        PARAMETER TESTING - ALPHA AND EPSILON
C
      REAL EPS,A,B,ALF,ALPHA,ALIM,BLIM,BET,ALFNUM,V
      REAL FALF,ANS,ERREST
      DIMENSION MAX(7),ALIM(7),BLIM(7),NFUN(7)
      DIMENSION JNUM(9),ALFNUM(9)
      COMMON/FALFCM/ALF,V,BET,M,JCALL,PARAM
      LOGICAL PARAM,JPRINT
      DATA MAX/30,50,69,101,25,1,25/
      DATA NFUN/1,1,2,3,4,5,6/
      DATA ALIM/-1.E0,6*0.E0/
      DATA BLIM/7*1.E0/
      DATA JNUM/5,3,4,4,5*1/
      DATA ALFNUM/3.E0,0.5E0,1.95E0,17.95E0,5*1.E0/
C
C        ALPHA AS A PARAMETER
C
C
C   SET THE OUTPUT UNIT TO IWRITE
C
       IWRITE = I1MACH(2)
      EPS =1.E-6
      PARAM=.TRUE.
      DO 1000 JFUN=1,7
         N=NFUN(JFUN)
         MAXA=MAX(JFUN)
         MAXBET=1
         IF(JFUN.EQ.7) MAXBET=8
         DO 900 JB=1,MAXBET
            BET=2**JB
            IF(N.EQ.1) WRITE(IWRITE,1)
            IF(N.EQ.2) WRITE(IWRITE,2)
            IF(N.EQ.3) WRITE(IWRITE,3)
            IF(N.EQ.4) WRITE(IWRITE,4)
            IF(N.EQ.5) WRITE(IWRITE,5)
            IF(N.EQ.6) WRITE(IWRITE,6)
            A=ALIM(JFUN)
            B=BLIM(JFUN)
            IF(N.EQ.6) WRITE(IWRITE,11) BET
            WRITE(IWRITE,10) A,B,EPS
            DO 50 J=1,MAXA
               JJ=J
               ALF=ALPHA(JJ,N)
               NN=JFUN
   50          CALL TEST(A,B,EPS,ALF,NN)
  900       CONTINUE
 1000    CONTINUE
C
C ACCURACY AS A PARAMETER
C
      PARAM=.FALSE.
      BET=32.
      DO 2000 NUM=1,4
         JFUN=JNUM(NUM)
         N=NFUN(JFUN)
         ALF=ALFNUM(NUM)
         IF(N.EQ.2) WRITE(IWRITE,2)
         IF(N.EQ.3) WRITE(IWRITE,3)
         IF(N.EQ.4) WRITE(IWRITE,4)
         IF(N.EQ.6) WRITE(IWRITE,6)
         IF(N.EQ.6) WRITE(IWRITE,11) BET
         WRITE(IWRITE,12) A,B,ALF
         DO 1500 JEPS=2,12
            EPS=10.**(2-JEPS)
            NN=JFUN
 1500       CALL TEST(A,B,EPS,ALF,NN)
 2000 CONTINUE
    1 FORMAT(51H0    TEST OF QUAD ON F(X)=(2**A)/(1.+(X*(2**A))**2))
    2 FORMAT(30H0    TEST OF QUAD ON F(X)=X**A)
    3 FORMAT(41H0    TEST OF QUAD ON F(X))=1.+COS(A*PI*X))
    4 FORMAT(47H0    TEST OF QUAD ON F(X)=(2**A)*EXP(-(2**A)*X))
    5 FORMAT(52H0    TEST OF QUAD ON F(X)=(2**A)**2*X*EXP(-(2**A)*X))
    6 FORMAT(27H0    TEST OF QUAD ON F(X)=B,
     X      20H*EXP(-B**2*(X-A)**2))
   10 FORMAT(1H0,10X,6HLIMITS,2F6.2,21H   ATTEMPTED ACCURACY,1PE12.2/
     X      /14X,1HA,8X,8HTRUE INT,2X,
     X      8HTRUE ERR,4X,8HCALC ERR,4X,5HJCALL,6X,5HKWARN//)
   12 FORMAT(1H0,12X,6HLIMITS,2F6.2,4H   A,1PE14.4/
     X      /12X,3HEPS,8X,8HTRUE INT,2X,
     X      8HTRUE ERR,4X,8HCALC ERR,4X,5HJCALL,6X,5HKWARN//)
   11 FORMAT(17X,1HB,F7.2)
      RETURN
      END
      REAL FUNCTION ALPHA(N,J)
C
      GO TO (1,2,3,4,5,6),J
    1 ALPHA=N-1
      RETURN
    2 ALPHA=FLOAT(N-101)/100.E0
      IF(N.GE.21) ALPHA=FLOAT(N-21)/20.E0-0.8E0
      IF(N.GE.37) ALPHA=FLOAT(N-37)/10.E0
      IF(N.GE.57) ALPHA=FLOAT(N-57)/4.E0+2.E0
      RETURN
    3 ALPHA=0.25E0*FLOAT(N)
      IF(N.GE.81) ALPHA=35.5E0+FLOAT(N-81)/20.E0
      RETURN
    4 ALPHA=N-1
      RETURN
    5 ALPHA=0.5E0*FLOAT(N-1)
      RETURN
    6 ALPHA=0.02E0*FLOAT(N)
      RETURN
      END
      SUBROUTINE TEST(A,B,EPS,ALP,N)
      COMMON/FALFCM/ALF,V,BET,M,JCALL,PARAM
      REAL A,B,ALF,EPS,ANS,ERREST,TRUE,F,ALP,BET,V,FALF
      LOGICAL PARAM
      EXTERNAL FALF
C
C   SET THE OUTPUT UNIT TO IWRITE
C
       IWRITE = I1MACH(2)
C
C
      JCALL=0
      M=N
      ALF=ALP
      V=2.**ALF
      CALL QUAD(FALF,A,B,EPS,ANS,ERREST)
      CALL ERROFF
      KWARN=0
      IF (ERREST .GT. EPS) KWARN=1
      M=-N
      TRUE=FALF(0.E0)
      ERR=TRUE-ANS
      IF(     PARAM) WRITE(IWRITE,1) ALF,TRUE,ERR,ERREST,JCALL,KWARN
      IF(.NOT.PARAM) WRITE(IWRITE,2) EPS,TRUE,ERR,ERREST,JCALL,KWARN
      RETURN
    1 FORMAT(F17.4,F12.4,1P2E12.2,2I8)
    2 FORMAT(5X,1PE12.2,0PF12.4,1P2E12.2,2I8)
      END
      REAL FUNCTION FALF(X)
      REAL X,ALPHA,PI,ALF,B,V,ERFC,Y
      COMMON/FALFCM/ALF,V,B,N,JCALL,PARAM
      LOGICAL PARAM
C
      DATA PI/3.14159265E0/
C
C      7-DECIMAL ERFC, HART NUMBER 5662
C
      ERFC(Y)=EXP(-Y**2)*(3.5322166+Y*(2.1539977+Y*0.57404837))/
     *   (3.5322162+Y*(6.1397195+Y*(3.9690912+Y)))
C
      M=IABS(N)
      IF(N.LE.0) GO TO (100,101,102,103,104,105,106),M
      JCALL=JCALL+1
      GO TO (1,1,2,3,4,5,6),M
C
    1 FALF=V/(1.E0+(X*V)**2)
      RETURN
    2 FALF=0.
      IF(X.GT.0.E0) FALF=X**ALF
      RETURN
    3 FALF=1.E0+COS(ALF*X*PI)
      RETURN
    4 FALF=V*EXP(-V*X)
      RETURN
    5 FALF=V**2*X*EXP(-V*X)
      RETURN
    6 FALF=B*EXP(-(B*(X-ALF))**2)
      RETURN
C
  100 FALF=2.E0*ATAN(V)
      RETURN
  101 FALF=ATAN(V)
      RETURN
  102 FALF=R1MACH(2)
      IF (ALF .GT. (-1.E0)) FALF=1.E0/(1.E0+ALF)
      RETURN
  103 IF (ALF .NE. 0.E0) FALF=1.E0+SIN(ALF*PI)/(ALF*PI)
      IF (ALF .EQ. 0.E0) FALF=2.E0
      RETURN
  104 FALF=1.E0-EXP(-V)
      RETURN
  105 FALF=1.E0-(1.E0+V)*EXP(-V)
      RETURN
  106 FALF=SQRT(PI)*(1.E0-0.5*(ERFC(B*ALF)+ERFC(B*(1.E0-ALF))))
      RETURN
      END
      SUBROUTINE TEST3
C
C        THIRD PACKAGE TO TEST QUAD
C
C TEST QUAD FOR EFFECTS OF ROUNDOFF IN FUNCTION RATHER THAN MACHINE.
C
      EXTERNAL FRAND
      REAL FRAND,ANS,ERREST,RAND,TRUE,ERR
      COMMON/NOISE/RAND,JCALL,N,NR
C
C   SET THE OUTPUT UNIT TO IWRITE
C
       IWRITE = I1MACH(2)
C
C
      DO 200 N=1,4
         RAND=0.E0
         JCALL = 0
         CALL QUAD(FRAND,0.E0,1.E0,1.E-7,TRUE,ERREST)
         CALL ERROFF
         KWARN=0
         IF (ERREST .GT. 1.E-10) KWARN=1
         WRITE(IWRITE,5) N,TRUE,ERREST,KWARN,JCALL
    5    FORMAT(1H0,I4,1PD15.8,1PD12.3,2I10)
         DO 150 NR=1,2
            WRITE(IWRITE,4) N,NR
    4       FORMAT(2I5)
            DO 100 JR=1,9
               JEXP=2-JR
               RAND=10.E0**JEXP
               WRITE(IWRITE,1) JEXP
               WRITE(IWRITE,3)
    1          FORMAT(18H0NOISE LEVEL 10**(,I3,1H))
    3          FORMAT(47H    "TRUE" ERR     EST ERR      KWARN     JCALL
     *)
               DO 50 NN=1,5
                  JCALL=0
                  CALL QUAD(FRAND,0.E0,1.E0,1.E-5,ANS,ERREST)
                  CALL ERROFF
                  KWARN=0
                  IF (ERREST .GT. 1.E-6) KWARN=1
                  ERR=TRUE-ANS
                  WRITE(IWRITE,2) ERR,ERREST,KWARN,JCALL
    2             FORMAT(1X,1P2D13.3,2I10)
   50          CONTINUE
  100       CONTINUE
  150    CONTINUE
  200 CONTINUE
      RETURN
      END
      REAL FUNCTION FRAND(X)
      REAL X,RAND,PI,RAN
      COMMON/NOISE/RAND,JCALL,N,NR
      DATA PI/3.14159265E0/
C
      JCALL=JCALL+1
C
      RAN=RAND*(2.*UNI(0)-1.)
         GO TO (1,2,3,4),N
    1    FRAND=8.*EXP(-8.*X)
         GO TO 10
    2    FRAND=SQRT(X)
         GO TO 10
    3    FRAND=1.+COS(1.95E0*PI*X)
         GO TO 10
    4    FRAND=1.+COS(17.95E0*PI*X)
         GO TO 10
   10 IF(NR.EQ.1) FRAND=FRAND+RAN
      IF(NR.EQ.2) FRAND=FRAND*(1.E0+RAN)
      RETURN
      END