#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#ifndef aTHX_
#	define aTHX_
#endif
#ifndef pTHX_
#	define pTHX_
#endif
#ifndef WARN_OVERFLOW
#	define WARN_OVERFLOW "WARNING:"
#endif
#ifndef warner
#	define warner warn
#endif
#ifndef ckWARN_d
#	define ckWARN_d(w)	1
#endif

char * Perl_scan_version(pTHX_ char *s, SV *rv);
SV * Perl_new_version(pTHX_ SV *ver);
SV * Perl_upg_version(pTHX_ SV *sv);
SV * Perl_vnumify(pTHX_ SV *vs);
SV * Perl_vstringify(pTHX_ SV *vs);
int Perl_vcmp(pTHX_ SV *lsv, SV *rsv);

#define vnumify(a)		Perl_vnumify(aTHX_ a)
#define vstringify(a)		Perl_vstringify(aTHX_ a)
#define vcmp(a,b)		Perl_vcmp(aTHX_ a,b)
#define scan_version(a,b)	Perl_scan_version(aTHX_ a,b)
#define new_version(a)		Perl_new_version(aTHX_ a)
#define upg_version(a)		Perl_upg_version(aTHX_ a)
