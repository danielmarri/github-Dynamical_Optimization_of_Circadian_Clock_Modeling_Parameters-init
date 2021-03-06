/* q7rgs.f -- translated by f2c (version 20100827).
   You must link the resulting object file with libf2c:
	on Microsoft Windows system, link with libf2c.lib;
	on Linux or Unix systems, link with .../path/to/libf2c.a -lm
	or, if you install libf2c.a in a standard place, with -lf2c -lm
	-- in that order, at the end of the command line, as in
		cc *.o -lf2c -lm
	Source for libf2c is in /netlib/f2c/libf2c.zip, e.g.,

		http://www.netlib.org/f2c/libf2c.zip
*/

#include "f2c.h"

/* Table of constant values */

static integer c__3 = 3;
static integer c__1 = 1;
static integer c__6 = 6;
static real c_b22 = 0.f;

/* Subroutine */ int q7rgs_(integer *ierr, integer *ipivot, integer *l, 
	integer *n, integer *nn, integer *nopivk, integer *p, real *q, real *
	r__, real *w)
{
    /* Initialized data */

    static real meps10 = 0.f;
    static real tiny = 0.f;

    /* System generated locals */
    integer q_dim1, q_offset, i__1, i__2;
    real r__1;

    /* Builtin functions */
    double sqrt(doublereal);

    /* Local variables */
    static integer i__, j, k;
    static real t, t1, t2, ak;
    static integer ii, kk;
    static real wk;
    static integer km1, lm1, kp1;
    static real big;
    extern doublereal r7mdc_(integer *);
    extern /* Subroutine */ int v7scl_(integer *, real *, real *, real *);
    extern doublereal d7tpr_(integer *, real *, real *);
    extern /* Subroutine */ int v7scp_(integer *, real *, real *);
    extern doublereal v2nrm_(integer *, real *);
    extern /* Subroutine */ int v2axy_(integer *, real *, real *, real *, 
	    real *), v7swp_(integer *, real *, real *);
    static logical ipinit;
    static real singtl;


/*  ***  COMPUTE QR FACTORIZATION VIA MODIFIED GRAM-SCHMIDT PROCEDURE */
/*  ***  WITH COLUMN PIVOTING  *** */

/*  ***  PARAMETER DECLARATIONS  *** */

/*     DIMENSION R(P*(P+1)/2) */

/* ----------------------------  DESCRIPTION  ---------------------------- */

/*        THIS ROUTINE COMPUTES COLUMNS  L  THROUGH  P  OF A QR FACTORI- */
/*     ZATION OF THE MATRIX  A  THAT IS ORIGINALLY STORED IN COLUMNS  L */
/*     THROUGH  P  OF  Q.  IT IS ASSUMED THAT COLUMNS 1 THROUGH  L-1  OF */
/*     THE FACTORIZATION HAVE ALREADY BEEN STORED IN  Q  AND  R.  THIS */
/*     CODE USES THE MODIFIED GRAM-SCHMIDT PROCEDURE WITH REORTHOGONALI- */
/*     ZATION AND, IF  NOPIVK  ALLOWS IT, WITH COLUMN PIVOTING -- IF */
/*     K .GT. NOPIVK,  THEN ORIGINAL COLUMN  K  IS ELIGIBLE FOR PIVOTING. */
/*     IF  IPIVOT(L) = 0  ON INPUT, THEN  IPIVOT  IS INITIALIZED SO THAT */
/*     IPIVOT(I) = I  FOR  I = L,...,P.  WHATEVER THE ORIGINAL VALUE OF */
/*     IPIVOT(L), THE CORRESPONDING ELEMENTS OF  IPIVOT  ARE INTERCHANGED */
/*     WHENEVER COLUMN PIVOTING OCCURS.  THUS IF  IPIVOT(L) = 0  ON IN- */
/*     PUT, THEN THE  Q  AND  R  RETURNED ARE SUCH THAT COLUMN  I  OF */
/*     Q*R  EQUALS COLUMN  IPIVOT(I)  OF THE ORIGINAL MATRIX  A.  THE UP- */
/*     PER TRIANGULAR MATRIX  R  IS STORED COMPACTLY BY COLUMNS, I.E., */
/*     THE OUTPUT VECTOR  R  CONTAINS  R(1,1), R(1,2), R(2,2), R(1,3), */
/*     R(2,3), ..., R(P,P) (IN THAT ORDER).  IF ALL GOES WELL, THEN THIS */
/*     ROUTINE SETS  IERR = 0.  BUT IF (PERMUTED) COLUMN  K  OF  A  IS */
/*     LINEARLY DEPENDENT ON (PERMUTED) COLUMNS 1,2,...,K-1, THEN  IERR */
/*     IS SET TO  K AND THE R MATRIX RETURNED HAS  R(I,J) = 0  FOR */
/*     I .GE. K  AND  J .GE. K.  IN THIS CASE COLUMNS  K  THROUGH  P */
/*     OF THE  Q  RETURNED ARE NOT ORTHONORMAL.  W IS A SCRATCH VECTOR. */
/*        THE ORIGINAL MATRIX  A  AND THE COMPUTED ORTHOGONAL MATRIX  Q */
/*     ARE  N BY P  MATRICES.  NN  IS THE LEAD DIMENSION OF THE ARRAY  Q */
/*     AND MUST SATISFY  NN .GE. N.  NO PARAMETER CHECKING IS DONE. */

/*        CODED BY DAVID M. GAY (FALL 1979, SPRING 1984). */

/* --------------------------  LOCAL VARIABLES  -------------------------- */

/* /+ */
/* / */
/* /6 */
/*     DATA ONE/1.0E+0/, REOTOL/0.25E+0/, TEN/1.E+1/, WTOL/0.75E+0/, */
/*    1     ZERO/0.0E+0/ */
/* /7 */
/* / */
    /* Parameter adjustments */
    --w;
    q_dim1 = *nn;
    q_offset = 1 + q_dim1;
    q -= q_offset;
    --ipivot;
    --r__;

    /* Function Body */

/* +++++++++++++++++++++++++++++++  BODY  ++++++++++++++++++++++++++++++++ */

    *ierr = 0;
    if (meps10 > 0.f) {
	goto L10;
    }
    meps10 = r7mdc_(&c__3) * 10.f;
    tiny = r7mdc_(&c__1);
    big = r7mdc_(&c__6);
    if (tiny * big < 1.f) {
	tiny = 1.f / big;
    }
L10:
    singtl = (real) max(*n,*p) * meps10;
    lm1 = *l - 1;
    j = *l * lm1 / 2;
    kk = j;
    ipinit = ipivot[*l] == 0;

/*  ***  INITIALIZE W, IPIVOT, DIAG(R), AND R(I,J) FOR I = 1,2,...,L-1 */
/*  ***  AND J = L,L+1,...,P. */

    i__1 = *p;
    for (i__ = *l; i__ <= i__1; ++i__) {
	if (ipinit) {
	    ipivot[i__] = i__;
	}
	t = v2nrm_(n, &q[i__ * q_dim1 + 1]);
	if (t > 0.f) {
	    goto L20;
	}
	w[i__] = 1.f;
	j += lm1;
	goto L40;
L20:
	w[i__] = 0.f;
	if (lm1 == 0) {
	    goto L40;
	}
	i__2 = lm1;
	for (k = 1; k <= i__2; ++k) {
	    ++j;
	    t1 = d7tpr_(n, &q[k * q_dim1 + 1], &q[i__ * q_dim1 + 1]);
	    r__[j] = t1;
	    r__1 = -t1;
	    v2axy_(n, &q[i__ * q_dim1 + 1], &r__1, &q[k * q_dim1 + 1], &q[i__ 
		    * q_dim1 + 1]);
/* Computing 2nd power */
	    r__1 = t1 / t;
	    w[i__] += r__1 * r__1;
/* L30: */
	}
L40:
	j = j + i__ - lm1;
	r__[j] = t;
/* L50: */
    }

/*  ***  MAIN LOOP  *** */

    i__1 = *p;
    for (k = *l; k <= i__1; ++k) {
	kk += k;
	kp1 = k + 1;
	if (k <= *nopivk) {
	    goto L70;
	}
	if (k >= *p) {
	    goto L70;
	}

/*        ***  FIND COLUMN WITH MINIMUM WEIGHT LOSS  *** */

	t = w[k];
	if (t <= 0.f) {
	    goto L70;
	}
	j = k;
	i__2 = *p;
	for (i__ = kp1; i__ <= i__2; ++i__) {
	    if (w[i__] >= t) {
		goto L60;
	    }
	    t = w[i__];
	    j = i__;
L60:
	    ;
	}
	if (j == k) {
	    goto L70;
	}

/*             ***  INTERCHANGE COLUMNS K AND J  *** */

	i__ = ipivot[k];
	ipivot[k] = ipivot[j];
	ipivot[j] = i__;
	w[j] = w[k];
	w[k] = t;
	i__ = j * (j + 1) / 2;
	t1 = r__[i__];
	r__[i__] = r__[kk];
	r__[kk] = t1;
	v7swp_(n, &q[k * q_dim1 + 1], &q[j * q_dim1 + 1]);
	if (k <= 1) {
	    goto L70;
	}
	i__ = i__ - j + 1;
	j = kk - k + 1;
	i__2 = k - 1;
	v7swp_(&i__2, &r__[i__], &r__[j]);

/*        ***  COLUMN K OF Q SHOULD BE NEARLY ORTHOGONAL TO THE PREVIOUS */
/*        ***  COLUMNS.  NORMALIZE IT, TEST FOR SINGULARITY, AND DECIDE */
/*        ***  WHETHER TO REORTHOGONALIZE IT. */

L70:
	ak = r__[kk];
	if (ak <= 0.f) {
	    goto L150;
	}
	t1 = ak;
	r__[kk] = 1.f;
	t2 = 1.f;
	wk = w[k];

/*        *** SET T TO THE NORM OF (Q(K,K),...,Q(N,K)) */
/*        *** AND CHECK FOR SINGULARITY. */

L80:
	if (wk < .75f) {
	    goto L90;
	}
	t = v2nrm_(n, &q[k * q_dim1 + 1]);
	if (t * t2 / ak > singtl) {
	    goto L100;
	}
	goto L150;
L90:
	t = sqrt(1.f - wk);
	if (t * t2 <= singtl) {
	    goto L150;
	}
	t *= ak;

L100:
	if (t < tiny) {
	    goto L150;
	}
	r__[kk] = t * r__[kk];
	r__1 = 1.f / t;
	v7scl_(n, &q[k * q_dim1 + 1], &r__1, &q[k * q_dim1 + 1]);
	if (t / t1 >= .25f) {
	    goto L120;
	}

/*     ***  REORTHOGONALIZE COLUMN K  *** */

	ak = 1.f;
	t2 = t * t2;
	wk = 0.f;
	j = kk - k;
	km1 = k - 1;
	i__2 = km1;
	for (i__ = 1; i__ <= i__2; ++i__) {
	    ++j;
	    t = d7tpr_(n, &q[i__ * q_dim1 + 1], &q[k * q_dim1 + 1]);
	    wk += t * t;
	    r__[j] += t * r__[kk];
/* L110: */
	    r__1 = -t;
	    v2axy_(n, &q[k * q_dim1 + 1], &r__1, &q[i__ * q_dim1 + 1], &q[k * 
		    q_dim1 + 1]);
	}
	t1 = 1.f;
	goto L80;

/*        ***  COMPUTE R(K,I) FOR I = K+1,...,P AND UPDATE Q  *** */

L120:
	if (k >= *p) {
	    goto L999;
	}
	j = kk + k;
	ii = kk;
	i__2 = *p;
	for (i__ = kp1; i__ <= i__2; ++i__) {
	    ii += i__;
	    t = d7tpr_(n, &q[k * q_dim1 + 1], &q[i__ * q_dim1 + 1]);
	    r__[j] = t;
	    j += i__;
	    r__1 = -t;
	    v2axy_(n, &q[i__ * q_dim1 + 1], &r__1, &q[k * q_dim1 + 1], &q[i__ 
		    * q_dim1 + 1]);
	    t1 = r__[ii];
	    if (t1 > 0.f) {
/* Computing 2nd power */
		r__1 = t / t1;
		w[i__] += r__1 * r__1;
	    }
/* L130: */
	}
/* L140: */
    }

/*  ***  SINGULAR Q  *** */

L150:
    *ierr = k;
    km1 = k - 1;
    j = kk;
    i__1 = *p;
    for (i__ = k; i__ <= i__1; ++i__) {
	i__2 = i__ - km1;
	v7scp_(&i__2, &r__[j], &c_b22);
	j += i__;
/* L160: */
    }

L999:
    return 0;
/*  ***  LAST CARD OF Q7RGS FOLLOWS  *** */
} /* q7rgs_ */

