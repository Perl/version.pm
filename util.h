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
SV * Perl_vnumify(pTHX_ SV *sv, SV *vs);
SV * Perl_vstringify(pTHX_ SV *sv, SV *vs);
int Perl_vcmp(pTHX_ SV *lsv, SV *rsv);

#define new_version        Perl_new_version
#define scan_version       Perl_scan_version
#define upg_version        Perl_upg_version
#define vcmp               Perl_vcmp
#define vnumify            Perl_vnumify
#define vstringify         Perl_vstringify
