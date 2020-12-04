C$TEST RANC
C TO RUN AS A MAIN PROGRAM REMOVE NEXT LINE
      SUBROUTINE RANC
C***********************************************************************
C
C  EXAMPLE OF USE OF THE PORT PROGRAM RANBYT
C
C***********************************************************************
      INTEGER IBYTE(4),IWRITE,I1MACH,K
      REAL R,RAND,UNI
C
C  SET THE CORRECT OUTPUT UNIT
C
      IWRITE = I1MACH(2)
C
C  PRINT OUT THE FIRST FIVE UNIFORM RANDOM VARIATES
C
      DO 1  K = 1,5
      RAND = UNI(0)
  1   WRITE (IWRITE, 9997) RAND
 9997 FORMAT(1H , E15.8)
C
C  NOW RESET TO THE ORIGINAL SEEDS
C  AND SEE HOW THE VARIATES LOOK AS BIT PATTERNS
C  (WRITTEN IN OCTAL WITH INTEGER VALUES GIVEN UNDERNEATH)
C
      CALL RANSET(12345,1073)
      DO 2  K = 1,5
      CALL RANBYT(R,IBYTE)
      WRITE (IWRITE, 9998) R, IBYTE
 9998 FORMAT(1H0, E15.8, 4(3X, O3))
C
      WRITE(IWRITE, 9999) IBYTE
 9999 FORMAT(16X, 4(3X, I3))
  2   CONTINUE
C
      STOP
      END