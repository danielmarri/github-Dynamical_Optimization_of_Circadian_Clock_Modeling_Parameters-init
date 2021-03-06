      SUBROUTINE  RMNF(D, FX, IV, LIV, LV, N, V, X)
C
C  ***  ITERATION DRIVER FOR   MNF...
C  ***  MINIMIZE GENERAL UNCONSTRAINED OBJECTIVE FUNCTION USING
C  ***  FINITE-DIFFERENCE GRADIENTS AND SECANT HESSIAN APPROXIMATIONS.
C
      INTEGER LIV, LV, N
      INTEGER IV(LIV)
      REAL D(N), FX, X(N), V(LV)
C     DIMENSION V(77 + N*(N+17)/2)
C
C  ***  PURPOSE  ***
C
C        THIS ROUTINE INTERACTS WITH SUBROUTINE   RMNG  IN AN ATTEMPT
C     TO FIND AN N-VECTOR  X*  THAT MINIMIZES THE (UNCONSTRAINED)
C     OBJECTIVE FUNCTION  FX = F(X)  COMPUTED BY THE CALLER.  (OFTEN
C     THE  X*  FOUND IS A LOCAL MINIMIZER RATHER THAN A GLOBAL ONE.)
C
C  ***  PARAMETERS  ***
C
C        THE PARAMETERS FOR  RMNF ARE THE SAME AS THOSE FOR   MNG
C     (WHICH SEE), EXCEPT THAT CALCF, CALCG, UIPARM, URPARM, AND UFPARM
C     ARE OMITTED, AND A PARAMETER  FX  FOR THE OBJECTIVE FUNCTION
C     VALUE AT X IS ADDED.  INSTEAD OF CALLING CALCG TO OBTAIN THE
C     GRADIENT OF THE OBJECTIVE FUNCTION AT X,  RMNF CALLS  S7GRD,
C     WHICH COMPUTES AN APPROXIMATION TO THE GRADIENT BY FINITE
C     (FORWARD AND CENTRAL) DIFFERENCES USING THE METHOD OF REF. 1.
C     THE FOLLOWING INPUT COMPONENT IS OF INTEREST IN THIS REGARD
C     (AND IS NOT DESCRIBED IN   MNG).
C
C V(ETA0)..... V(42) IS AN ESTIMATED BOUND ON THE RELATIVE ERROR IN THE
C             OBJECTIVE FUNCTION VALUE COMPUTED BY CALCF...
C                  (TRUE VALUE) = (COMPUTED VALUE) * (1 + E),
C             WHERE ABS(E) .LE. V(ETA0).  DEFAULT = MACHEP * 10**3,
C             WHERE MACHEP IS THE UNIT ROUNDOFF.
C
C        THE OUTPUT VALUES IV(NFCALL) AND IV(NGCALL) HAVE DIFFERENT
C     MEANINGS FOR   MNF THAN FOR   MNG...
C
C IV(NFCALL)... IV(6) IS THE NUMBER OF CALLS SO FAR MADE ON CALCF (I.E.,
C             FUNCTION EVALUATIONS) EXCLUDING THOSE MADE ONLY FOR
C             COMPUTING GRADIENTS.  THE INPUT VALUE IV(MXFCAL) IS A
C             LIMIT ON IV(NFCALL).
C IV(NGCALL)... IV(30) IS THE NUMBER OF FUNCTION EVALUATIONS MADE ONLY
C             FOR COMPUTING GRADIENTS.  THE TOTAL NUMBER OF FUNCTION
C             EVALUATIONS IS THUS  IV(NFCALL) + IV(NGCALL).
C
C  ***  REFERENCES  ***
C
C 1. STEWART, G.W. (1967), A MODIFICATION OF DAVidoN*S MINIMIZATION
C        METHOD TO ACCEPT DIFFERENCE APPROXIMATIONS OF DERIVATIVES,
C        J. ASSOC. COMPUT. MACH. 14, PP. 72-83.
C.
C  ***  GENERAL  ***
C
C     CODED BY DAVID M. GAY (AUGUST 1982).
C
C----------------------------  DECLARATIONS  ---------------------------
C
      REAL  D7TPR
      EXTERNAL IVSET,  D7TPR,  S7GRD,  RMNG,  V7SCP
C
C IVSET.... SUPPLIES DEFAULT PARAMETER VALUES.
C  D7TPR... RETURNS INNER PRODUCT OF TWO VECTORS.
C  S7GRD... COMPUTES FINITE-DIFFERENCE GRADIENT APPROXIMATION.
C  RMNG.... REVERSE-COMMUNICATION ROUTINE THAT DOES   MNG ALGORITHM.
C  V7SCP... SETS ALL ELEMENTS OF A VECTOR TO A SCALAR.
C
      INTEGER ALPHA, G1, I, IV1, J, K, W
      REAL ZERO
C
C  ***  SUBSCRIPTS FOR IV   ***
C
      INTEGER ETA0, F, G, LMAT, NEXTV, NGCALL, NITER, SGIRC, TOOBIG,
     1        VNEED
C
C/6
C     DATA ETA0/42/, F/10/, G/28/, LMAT/42/, NEXTV/47/, NGCALL/30/,
C    1     NITER/31/, SGIRC/57/, TOOBIG/2/, VNEED/4/
C/7
      PARAMETER (ETA0=42, F=10, G=28, LMAT=42, NEXTV=47, NGCALL=30,
     1           NITER=31, SGIRC=57, TOOBIG=2, VNEED=4)
C/
C/6
C     DATA ZERO/0.E+0/
C/7
      PARAMETER (ZERO=0.E+0)
C/
C
C+++++++++++++++++++++++++++++++  BODY  ++++++++++++++++++++++++++++++++
C
      IV1 = IV(1)
      IF (IV1 .EQ. 1) GO TO 10
      IF (IV1 .EQ. 2) GO TO 50
      IF (IV(1) .EQ. 0) CALL IVSET(2, IV, LIV, LV, V)
      IV1 = IV(1)
      IF (IV1 .EQ. 12 .OR. IV1 .EQ. 13) IV(VNEED) = IV(VNEED) + 2*N + 6
      IF (IV1 .EQ. 14) GO TO 10
      IF (IV1 .GT. 2 .AND. IV1 .LT. 12) GO TO 10
      G1 = 1
      IF (IV1 .EQ. 12) IV(1) = 13
      GO TO 20
C
 10   G1 = IV(G)
C
 20   CALL  RMNG(D, FX, V(G1), IV, LIV, LV, N, V, X)
      IF (IV(1) - 2) 999, 30, 70
C
C  ***  COMPUTE GRADIENT  ***
C
 30   IF (IV(NITER) .EQ. 0) CALL  V7SCP(N, V(G1), ZERO)
      J = IV(LMAT)
      K = G1 - N
      DO 40 I = 1, N
         V(K) =  D7TPR(I, V(J), V(J))
         K = K + 1
         J = J + I
 40      CONTINUE
C     ***  UNDO INCREMENT OF IV(NGCALL) DONE BY  RMNG  ***
      IV(NGCALL) = IV(NGCALL) - 1
C     ***  STORE RETURN CODE FROM  S7GRD IN IV(SGIRC)  ***
      IV(SGIRC) = 0
C     ***  X MAY HAVE BEEN RESTORED, SO COPY BACK FX... ***
      FX = V(F)
      GO TO 60
C
C     ***  GRADIENT LOOP  ***
C
 50   IF (IV(TOOBIG) .NE. 0) GO TO 10
C
 60   G1 = IV(G)
      ALPHA = G1 - N
      W = ALPHA - 6
      CALL  S7GRD(V(ALPHA), D, V(ETA0), FX, V(G1), IV(SGIRC), N, V(W),X)
      IF (IV(SGIRC) .EQ. 0) GO TO 10
         IV(NGCALL) = IV(NGCALL) + 1
         GO TO 999
C
 70   IF (IV(1) .NE. 14) GO TO 999
C
C  ***  STORAGE ALLOCATION  ***
C
      IV(G) = IV(NEXTV) + N + 6
      IV(NEXTV) = IV(G) + N
      IF (IV1 .NE. 13) GO TO 10
C
 999  RETURN
C  ***  LAST CARD OF  RMNF FOLLOWS  ***
      END
