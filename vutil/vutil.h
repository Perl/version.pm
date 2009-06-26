#include "ppport.h"

#if PERL_VERSION < 10
const char * Perl_scan_version(pTHX_ const char *s, SV *rv, bool qv);
SV * Perl_new_version(pTHX_ SV *ver);
SV * Perl_upg_version(pTHX_ SV *sv, bool qv);
bool Perl_vverify(pTHX_ SV *vs);
SV * Perl_vnumify(pTHX_ SV *vs);
SV * Perl_vnormal(pTHX_ SV *vs);
SV * Perl_vstringify(pTHX_ SV *vs);
int Perl_vcmp(pTHX_ SV *lsv, SV *rsv);

#define SCAN_VERSION(a,b,c)	Perl_scan_version(aTHX_ a,b,c)
#define NEW_VERSION(a)		Perl_new_version(aTHX_ a)
#define UPG_VERSION(a,b)	Perl_upg_version(aTHX_ a, b)
#define vverify(a)		Perl_vverify(aTHX_ a)
#define vnumify(a)		Perl_vnumify(aTHX_ a)
#define vnormal(a)		Perl_vnormal(aTHX_ a)
#define voriginal(a)		Perl_voriginal(aTHX_ a)
#define vstringify(a)		Perl_vstringify(aTHX_ a)
#define vcmp(a,b)		Perl_vcmp(aTHX_ a,b)
#else
const char * Perl_scan_version2(pTHX_ const char *s, SV *rv, bool qv);
SV * Perl_new_version2(pTHX_ SV *ver);
SV * Perl_upg_version2(pTHX_ SV *sv, bool qv);
#define SCAN_VERSION(a,b,c)	Perl_scan_version2(aTHX_ a,b,c)
#define NEW_VERSION(a)		Perl_new_version2(aTHX_ a)
#define UPG_VERSION(a,b)	Perl_upg_version2(aTHX_ a, b)
#define vcmp(a,b)		Perl_vcmp(aTHX_ a,b)
#endif

SV * Perl_vstringify2(pTHX_ SV *vs);
#define vstringify2(a)		Perl_vstringify2(aTHX_ a)
