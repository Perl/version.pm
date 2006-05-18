#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"

#ifndef PERL_ABS
#define PERL_ABS(x) ((x) < 0 ? -(x) : (x))
#endif

#ifndef WARN_MISC
#define WARN_MISC (1)
#endif

#ifndef packWARN
#define packWARN(a) (a)
#endif

#ifndef SVf
#define SVf "_"
#endif

#ifndef SvVSTRING_mg
#define SvVSTRING_mg(sv) (SvMAGICAL(sv) \
    ? mg_find(sv,PERL_MAGIC_vstring) : NULL)
#endif

#ifndef dVAR
#define dVAR 
#endif

#ifndef my_snprintf
#define my_snprintf snprintf
#endif

#ifndef STR_WITH_LEN
#define STR_WITH_LEN(s)  (s ""), (sizeof(s)-1)
#endif

#ifndef hv_fetchs
#define hv_fetchs(hv,key,lval) Perl_hv_fetch(aTHX_ hv, STR_WITH_LEN(key), lval)
#endif

#ifndef sv_catpvs
#  if PERL_VERSION < 8
#    define sv_catpvs(sv, str) Perl_sv_catpvn(aTHX_ sv, STR_WITH_LEN(str))
#  else
#    define sv_catpvs(sv, str) Perl_sv_catpvn_flags(aTHX_ sv, STR_WITH_LEN(str), SV_GMAGIC )
#  endif
#endif

const char * Perl_scan_version(pTHX_ const char *s, SV *rv, bool qv);
SV * Perl_new_version(pTHX_ SV *ver);
SV * Perl_upg_version(pTHX_ SV *sv);
bool Perl_vverify(pTHX_ SV *vs);
SV * Perl_vnumify(pTHX_ SV *vs);
SV * Perl_vnormal(pTHX_ SV *vs);
SV * Perl_vstringify(pTHX_ SV *vs);
int Perl_vcmp(pTHX_ SV *lsv, SV *rsv);

#define scan_version(a,b,c)	Perl_scan_version(aTHX_ a,b,c)
#define new_version(a)		Perl_new_version(aTHX_ a)
#define upg_version(a)		Perl_upg_version(aTHX_ a)
#define vverify(a)		Perl_vverify(aTHX_ a)
#define vnumify(a)		Perl_vnumify(aTHX_ a)
#define vnormal(a)		Perl_vnormal(aTHX_ a)
#define vstringify(a)		Perl_vstringify(aTHX_ a)
#define vcmp(a,b)		Perl_vcmp(aTHX_ a,b)
