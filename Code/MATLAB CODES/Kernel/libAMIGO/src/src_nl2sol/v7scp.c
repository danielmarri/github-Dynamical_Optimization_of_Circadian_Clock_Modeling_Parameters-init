/* v7scp.f -- translated by f2c (version 20100827).
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

/* Subroutine */ int v7scp_(integer *p, real *y, real *s)
{
    /* System generated locals */
    integer i__1;

    /* Local variables */
    static integer i__;


/*  ***  SET P-VECTOR Y TO SCALAR S  *** */



    /* Parameter adjustments */
    --y;

    /* Function Body */
    i__1 = *p;
    for (i__ = 1; i__ <= i__1; ++i__) {
/* L10: */
	y[i__] = *s;
    }
    return 0;
} /* v7scp_ */

