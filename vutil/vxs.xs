#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#define NEED_sv_2pv_nolen_GLOBAL
#include "ppport.h"
#include "vutil.h"

/* --------------------------------------------------
 * $Revision: 2.5 $
 * --------------------------------------------------*/

typedef     SV *version_vxs;

MODULE = version::vxs	PACKAGE = version::vxs

PROTOTYPES: DISABLE
VERSIONCHECK: DISABLE

BOOT:
	/* register the overloading (type 'A') magic */
	PL_amagic_generation++;
	newXS("version::vxs::()", XS_version__vxs_noop, file);
	newXS("version::vxs::(\"\"", XS_version__vxs_stringify, file);
	newXS("version::vxs::(0+", XS_version__vxs_numify, file);
	newXS("version::vxs::(cmp", XS_version__vxs_vcmp, file);
	newXS("version::vxs::(<=>", XS_version__vxs_vcmp, file);
	newXS("version::vxs::(bool", XS_version__vxs_boolean, file);
	newXS("version::vxs::(nomethod", XS_version__vxs_noop, file);
	newXS("UNIVERSAL::VERSION", XS_version__vxs_VERSION, file);

void
new(...)
PPCODE:
{
    SV *vs = ST(1);
    SV *rv;
    const char * const classname = 
    	sv_isobject(ST(0)) /* get the class if called as an object method */
	    ? HvNAME(SvSTASH(SvRV(ST(0))))
	    : (char *)SvPV_nolen(ST(0));

    if (items > 3)
	Perl_croak(aTHX_ "Usage: version::new(class, version)");

    if ( items == 1 || vs == &PL_sv_undef ) { /* no param or explicit undef */
	/* create empty object */
	vs = sv_newmortal();
	sv_setpvn(vs,"",0);
    }
    else if (items == 3 ) {
	STRLEN n_a;
	vs = sv_newmortal();
	sv_setpvf(vs,"v%s",SvPV(ST(2),n_a));
    }

    rv = new_version(vs);
    if ( strcmp(classname,"version::vxs") != 0 ) /* inherited new() */
#if PERL_VERSION == 5
	sv_bless(rv, gv_stashpv((char *)classname, GV_ADD));
#else
	sv_bless(rv, gv_stashpv(classname, GV_ADD));
#endif

    PUSHs(sv_2mortal(rv));
}

void
stringify (lobj,...)
    version_vxs	lobj
PPCODE:
{
    PUSHs(sv_2mortal(vstringify2(lobj)));
}

void
numify (lobj,...)
    version_vxs	lobj
PPCODE:
{
    PUSHs(sv_2mortal(vnumify(lobj)));
}

void
normal(ver)
    SV *ver
PPCODE:
{
    PUSHs(sv_2mortal(vnormal(ver)));
}

void
vcmp (lobj,...)
    version_vxs	lobj
PPCODE:
{
    SV *rs;
    SV *rvs;
    SV *robj = ST(1);
    const IV  swap = (IV)SvIV(ST(2));

    if ( ! sv_derived_from(robj, "version::vxs") )
    {
	robj = sv_2mortal(new_version(robj));
    }
    rvs = SvRV(robj);

    if ( swap )
    {
        rs = newSViv(vcmp(robj,lobj));
    }
    else
    {
        rs = newSViv(vcmp(lobj,robj));
    }

    PUSHs(sv_2mortal(rs));
}

void
boolean(lobj,...)
    version_vxs	lobj
PPCODE:
{
    SV	* const rs = newSViv( vcmp(lobj,new_version(newSVpvs("0"))) );
    PUSHs(sv_2mortal(rs));
}

void
noop(lobj,...)
    version_vxs	lobj
CODE:
{
    Perl_croak(aTHX_ "operation not supported with version object");
}

void
is_alpha(lobj)
    version_vxs	lobj	
PPCODE:
{
    if ( hv_exists((HV*)lobj, "alpha", 5 ) )
	XSRETURN_YES;
    else
	XSRETURN_NO;
}

void
qv(ver)
    SV *ver
PPCODE:
{
#ifdef SvVOK
    if ( !SvVOK(ver) ) { /* not already a v-string */
#endif
	SV * const rv = sv_newmortal();
	sv_setsv(rv,ver); /* make a duplicate */
	upg_version(rv, TRUE);
	PUSHs(rv);
#ifdef SvVOK
    }
    else
    {
	PUSHs(sv_2mortal(new_version(ver)));
    }
#endif
}

void
VERSION(sv,...)
    SV *sv
PPCODE:
{
    HV *pkg;
    GV **gvp;
    GV *gv;
    const char *undef;

    if (SvROK(sv)) {
        sv = (SV*)SvRV(sv);
        if (!SvOBJECT(sv))
            Perl_croak(aTHX_ "Cannot find version of an unblessed reference");
        pkg = SvSTASH(sv);
    }
    else {
        pkg = gv_stashsv(sv, FALSE);
    }

    gvp = pkg ? (GV**)hv_fetchs(pkg,"VERSION",FALSE) : Null(GV**);

    if (gvp && isGV(gv = *gvp) && (sv = GvSV(gv)) && SvOK(sv)) {
        SV * const nsv = sv_newmortal();
        sv_setsv(nsv, sv);
        sv = nsv;
	if ( !sv_derived_from(sv, "version::vxs"))
	    upg_version(sv, FALSE);
        undef = NULL;
    }
    else {
        sv = (SV*)&PL_sv_undef;
        undef = "(undef)";
    }

    if (items > 1) {
	SV *req = ST(1);
	STRLEN len;

	if (undef) {
	     if (pkg) {
		 const char * const name = HvNAME(pkg);
#if PERL_VERSION == 5
		 Perl_croak(aTHX_ "%s version %s required--this is only version ",
		 	    name, SvPVx(req, len));
#else
		 Perl_croak(aTHX_ "%s does not define $%s::VERSION--version check failed",
			    name, name);
#endif
	     }
	     else {
		 const char * const name = SvPVx(ST(0), len);
#if PERL_VERSION >= 8
		 Perl_croak(aTHX_ "%s defines neither package nor VERSION--version check failed", name );
#else
		 Perl_croak(aTHX_ "%s does not define $%s::VERSION--version check failed",
			    name, name);
#endif
	     }
	}

        if ( !sv_derived_from(req, "version")) {
	    /* req may very well be R/O, so create a new object */
	    req = sv_2mortal( new_version(req) );
	}
	

	if ( vcmp( req, sv ) > 0 ) {
	    if ( hv_exists((HV*)SvRV(req), "qv", 2 ) ) {
		Perl_croak(aTHX_ "%s version %"SVf" required--"
		   "this is only version %"SVf" ", HvNAME(pkg),
		       SVfARG(vnormal(req)),
		       SVfARG(vnormal(sv)));
	    }
	    else {
		Perl_croak(aTHX_ "%s version %"SVf" required--"
		   "this is only version %"SVf" ", HvNAME(pkg),
		       SVfARG(vstringify2(req)),
		       SVfARG(vstringify2(sv)));
	    }
	}
    }

    if ( SvOK(sv) && sv_derived_from(sv, "version::vxs") ) {
	ST(0) = vstringify2(sv);
    } else {
	ST(0) = sv;
    }

    XSRETURN(1);
}
