      SUBROUTINE FFT(A,B,NTOT,N,NSPAN,ISN)
C
C FFT SETS UP STACK STORAGE FOR F1FT (WHICH IS
C SINGLETON S ORIGINAL FFT), GOES INTO RECOVERY MODE,
C CALLS F1FT, AND ON RETURN CHECKS FOR, AND REINTERPRETS
C ANY ERRORS THAT HAVE OCCURRED, THEN RESTORES THE
C PREVIOUS RECOVERY MODE AND RETURNS.
C
C FFT MAKES ERRORS IN THE CALLING PARAMETERS FATAL,
C BUT OTHER ERRORS RECOVERABLE, SINCE FFT, IN TURN, IS CALLED BY
C OUTER LEVEL ROUTINES.
C
C STORAGE IN THE DYNAMIC STORAGE STACK IS SET UP FOR
C NFAC(11),NP(209),AT(23),CK(23),BT(23),SK(23), REQUIRING
C 220 INTEGER LOCATIONS AND 92 REAL LOCATIONS.
C
C
C
C     INPUT
C
C       A     -VECTOR OF SIZE NTOT CONTAINING REAL ELEMENTS OF DATA
C       B     -VECTOR OF SIZE NTOT CONTAINING IMAGINARY ELEMENTS OF DATA
C      NTOT   -TOTAL NUMBER OF COMPLEX DATA POINTS
C       N     -NUMBER OF COMPLEX DATA POINTS OF THE CURRENT VARIABLE
C     NSPAN  -NUMBER OF ELEMENTS OF BOTH A AND B NECESSARY TO SPAN
C              ALL VALUES OF THE CURRENT VARIABLE
C              (FOR A SINGLE VARIATE TRANSFORM NTOT=N=NSPAN.  FOR A
C              MULTIVARIATE TRANSFORM N AND NSPAN ARE DIFFERENT IN
C              EACH CALL STATEMENT.  SEE EXAMPLE BELOW).
C      ISN   -DETERMINES BY SIGN THE TYPE OF TRANSFORM BEING COMPUTED,
C              FORWARD OR INVERSE
C             -INDICATES BY ABSOLUTE VALUE THE VECTOR ARRANGEMENT OF
C              INPUT DATA (AND TRANSFORM OUTPUT)
C             =+1 COMPLEX INPUT DATA ARE IN TWO VECTORS, A AND B.
C              REAL COMPONENTS IN A, IMAGINARY COMPONENTS IN B.
C             =-1 FOURIER COEFFICIENT INPUT VALUES ARE IN TWO VECTORS,
C              A AND B.  COSINE VALUES IN A, SINE VALUES IN B.
C             =+2 COMPLEX INPUT DATA ARE STORED ALTERNATELY IN A
C              SINGLE COMPLEX VECTOR, A.  REAL VALUES ARE
C              IN A(1),A(3),... AND IMAGINARY VALUES ARE
C              IN A(2),A(4),....  SECOND ARGUMENT OF
C              FFT SHOULD BE A(2).  (SEE EXAMPLE.)
C             =-2 FOURIER COEFFICIENT INPUT VALUES ARE STORED ALTER-
C              NATELY IN A SINGLE VECTOR, A.  COSINE VALUES ARE IN
C              A(1),A(3),... AND SINE VALUES ARE IN A(2),A(4),....
C              SECOND ARGUMENT OF FFT SHOULD BE A(2).
C
C
C     OUTPUT
C
C       A     -VECTOR OF SIZE NTOT CONTAINING COSINE COMPONENTS OF
C              FOURIER COEFFICIENTS
C       B     -VECTOR OF SIZE NTOT CONTAINING SINE COMPONENTS OF FOURIER
C              COEFFICIENTS
C
C IF ISN=1 MULTIPLY OUTPUT BY 2/N FOR UNIT MAGNITUDE.
C
C IF ISN=2 OUTPUT WILL ALTERNATE IN A SINGLE VECTOR, A.  COSINE
C COEFFICIENTS IN A(1),A(3),... AND SINE COEFFICIENTS IN A(2),A(4),....
C OUTPUT SHOULD BE MULTIPLIED BY 4/N FOR UNIT MAGNITUDE.
C
C
C NUMBER OF FACTORS OF N MUST NOT EXCEED 11.
C MAXIMUM PRIME FACTOR OF N MUST NOT EXCEED 23.
C PRODUCT OF THE SQUARE-FREE FACTORS, IF THERE EXISTS MORE THAN ONE,
C MUST NOT EXCEED 210.
C
C
C     ERROR STATES
C          1.  N IS LESS THAN 2
C          2.  NTOT IS LESS THAN N
C          3.  NSPAN IS LESS THAN N
C          4.  ABS(ISN) IS GREATER THAN 2
C          5.  PRIME FACTOR .GT. 23
C              (RECOVERABLE)
C          6.  SQUARE-FREE FACTOR PRODUCT .GT. 210
C              (RECOVERABLE)
C
C
C EXAMPLES -
C
C TRANSFORM OF N COMPLEX DATA VALUES STORED IN TWO VECTORS -
C                CALL FFT(A,B,N,N,N,1)
C
C INVERSE TRANSFORM OF FOURIER COEFFICIENTS STORED IN TWO VECTORS -
C                CALL FFT(A,B,N,N,N,-1)
C
C TRANSFORM OF N COMPLEX DATA VALUES STORED ALTERNATELY IN A SINGLE
C COMPLEX VECTOR -
C                CALL FFT(A,A(2),2*N,N,2*N,2)
C
C INVERSE TRANSFORM OF N FOURIER COEFFICIENTS, COSINE AND SINE COMPO-
C NENTS STORED ALTERNATELY IN A SINGLE VECTOR -
C                CALL FFT(A,A(2),2*N,N,2*N,-2)
C
C FOR A MULTIVARIATE TRANSFORM THERE IS NO LIMIT ON THE NUMBER OF
C IMPLIED SUBSCRIPTS.  FFT SHOULD BE CALLED ONCE FOR EACH VARIABLE
C AND THE CALLS MAY BE MADE IN ANY ORDER.
C
C TRANSFORM OF A TRI-VARIATE, A(N1,N2,N3), B(N1,N2,N3) -
C                NTOT=N1*N2*N3
C                CALL FFT(A,B,NTOT,N1,N1,1)
C                CALL FFT(A,B,NTOT,N2,N1*N2,1)
C                CALL FFT(A,B,NTOT,N3,NTOT,1)
C
C
C FOR TRANSFORM OF COMPLETELY REAL DATA USE RLTR IN CONJUNCTION WITH
C FFT.
C
C
C OTHER ROUTINES CALLED -  SETERR
C
C
C THE PORT LIBRARY VERSION OF FFT IS AS SHOWN IN THE SINGLETON
C REFERENCE EXCEPT FOR CHANGES IN THE ERROR HANDLING.
C
C
C REFERENCE-  SINGLETON, R. C.,  AN ALGORITHM FOR COMPUTING THE MIXED
C             RADIX FAST FOURIER TRANSFORM , IEEE TRANSACTIONS ON AUDIO
C             AND ELECTROACOUSTICS, VOL. AU-17, NO. 2, JUNE, 1969
C             PP. 93-103.
C
C COMMON AREA
      COMMON/CSTAK/DSTAK(500)
C
      INTEGER ISTAK(1000)
      REAL RSTAK(1000)
      REAL A(1),B(1)
      DOUBLE PRECISION DSTAK
C
      EQUIVALENCE (DSTAK(1),ISTAK(1))
      EQUIVALENCE (DSTAK(1),RSTAK(1))
C
C  THE FOLLOWING TWO CONSTANTS SHOULD AGREE WITH THE ARRAY DIMENSIONS.
C
C
C  TEST THE VALIDITY OF THE INPUTS
C
C/6S
C     IF(N .LT. 2) CALL SETERR(
C    1   23H FFT - N IS LESS THAN 2,23,1,2)
C     IF(NTOT .LT. N) CALL SETERR(
C    1   26H FFT - NTOT IS LESS THAN N,26,2,2)
C     IF(NSPAN .LT. N) CALL SETERR(
C    1   27H FFT - NSPAN IS LESS THAN N,27,3,2)
C     IF(IABS(ISN) .GT. 2) CALL SETERR(
C    1   39H FFT - ISN HAS MAGNITUDE GREATER THAN 2,39,4,2)
C/7S
      IF(N .LT. 2) CALL SETERR(
     1   ' FFT - N IS LESS THAN 2',23,1,2)
      IF(NTOT .LT. N) CALL SETERR(
     1   ' FFT - NTOT IS LESS THAN N',26,2,2)
      IF(NSPAN .LT. N) CALL SETERR(
     1   ' FFT - NSPAN IS LESS THAN N',27,3,2)
      IF(IABS(ISN) .GT. 2) CALL SETERR(
     1   ' FFT - ISN HAS MAGNITUDE GREATER THAN 2',39,4,2)
C/
C
C ENTER THE RECOVERY MODE (STORING THE PREVIOUS)
C
      CALL ENTER(1)
C
C SET UP STORAGE IN THE DYNAMIC STORAGE STACK
C
      INFAC = ISTKGT(220,2)
      INP   = INFAC + 11
C
      IAT   = ISTKGT(92,3)
      ICK   = IAT   + 23
      IBT   = ICK   + 23
      ISK   = IBT   + 23
C
C  CALL THE SUBPROGRAM, F1FT, WHICH DOES THE WORK.
C
      CALL F1FT(A,B,NTOT,N,NSPAN,ISN,
     1         ISTAK(INFAC),ISTAK(INP),RSTAK(IAT),
     1         RSTAK(ICK),RSTAK(IBT),RSTAK(ISK))
C
C  CHECK FOR ERRORS FROM F1FT
C
      IF (NERROR(NERR) .EQ. 0) GO TO 10
      CALL ERROFF
C
C/6S
C     IF (NERR .EQ. 1) CALL SETERR(
C    1   35H FFT - PRIME FACTOR GREATER THAN 23,35,5,1)
C/7S
      IF (NERR .EQ. 1) CALL SETERR(
     1   ' FFT - PRIME FACTOR GREATER THAN 23',35,5,1)
C/
C
C/6S
C     IF (NERR .EQ. 2) CALL SETERR(
C    1   43H FFT - SQUARE-FREE PRODUCT GREATER THAN 210,43,6,1)
C/7S
      IF (NERR .EQ. 2) CALL SETERR(
     1   ' FFT - SQUARE-FREE PRODUCT GREATER THAN 210',43,6,1)
C/
C
 10   CALL LEAVE
C
      RETURN
      END