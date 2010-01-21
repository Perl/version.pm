#include "ppport.h"

# if PERL_VERSION == 10 && (PERL_SUBVERSION == 0 || PERL_SUBVERSION == 1) 

const char * Perl_scan_version2(pTHX_ const char *s, SV *rv, bool qv);
SV * Perl_new_version2(pTHX_ SV *ver);
SV * Perl_upg_version2(pTHX_ SV *sv, bool qv);
SV * Perl_vstringify2(pTHX_ SV *vs);
#define SCAN_VERSION(a,b,c)	Perl_scan_version2(aTHX_ a,b,c)
#define NEW_VERSION(a)		Perl_new_version2(aTHX_ a)
#define UPG_VERSION(a,b)	Perl_upg_version2(aTHX_ a, b)
#define VSTRINGIFY(a)		Perl_vstringify2(aTHX_ a)

# else

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
#define VSTRINGIFY(a)		Perl_vstringify(aTHX_ a)
#define vverify(a)		Perl_vverify(aTHX_ a)
#define vnumify(a)		Perl_vnumify(aTHX_ a)
#define vnormal(a)		Perl_vnormal(aTHX_ a)
#define voriginal(a)		Perl_voriginal(aTHX_ a)
#define vcmp(a,b)		Perl_vcmp(aTHX_ a,b)

# endif

const char *
Perl_prescan_version(pTHX_ const char *s, bool strict,
		     bool *sqv, int *ssaw_decimal, int *swidth, bool *salpha);
#define prescan_version(a,b,c,d,e,f)	Perl_prescan_version(aTHX_ a,b,c,d,e,f)
#define isVERSION(a,b) \
	(a != Perl_prescan_version(aTHX_ a, b, NULL, NULL, NULL, NULL))

#define PERL_ARGS_ASSERT_PRESCAN_VERSION	\
	assert(s); assert(strict); assert(sqv); assert(ssaw_period);\
	assert(swidth); assert(salpha);
#define PERL_ARGS_ASSERT_SCAN_VERSION	\
	assert(s); assert(rv)
#define PERL_ARGS_ASSERT_NEW_VERSION	\
	assert(ver)
#define PERL_ARGS_ASSERT_UPG_VERSION	\
	assert(ver)
#define PERL_ARGS_ASSERT_VVERIFY	\
	assert(vs)
#define PERL_ARGS_ASSERT_VNUMIFY	\
	assert(vs)
#define PERL_ARGS_ASSERT_VNORMAL	\
	assert(vs)
#define PERL_ARGS_ASSERT_VSTRINGIFY	\
	assert(vs)
#define PERL_ARGS_ASSERT_VCMP	\
	assert(lhv); assert(rhv)
