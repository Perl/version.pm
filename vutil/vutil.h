#include "ppport.h"

const char * Perl_scan_version(pTHX_ const char *s, SV *rv, bool qv);
SV * Perl_new_version(pTHX_ SV *ver);
SV * Perl_upg_version(pTHX_ SV *sv, bool qv);
bool Perl_vverify(pTHX_ SV *vs);
SV * Perl_vnumify(pTHX_ SV *vs);
SV * Perl_vnormal(pTHX_ SV *vs);
SV * Perl_vstringify(pTHX_ SV *vs);
int Perl_vcmp(pTHX_ SV *lsv, SV *rsv);

#define scan_version(a,b,c)	Perl_scan_version(aTHX_ a,b,c)
#define new_version(a)		Perl_new_version(aTHX_ a)
#define upg_version(a,b)	Perl_upg_version(aTHX_ a, b)
#define vverify(a)		Perl_vverify(aTHX_ a)
#define vnumify(a)		Perl_vnumify(aTHX_ a)
#define vnormal(a)		Perl_vnormal(aTHX_ a)
#define vstringify(a)		Perl_vstringify(aTHX_ a)
#define vcmp(a,b)		Perl_vcmp(aTHX_ a,b)
