#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "util.h"

/* --------------------------------------------------
 * $Revision: 1.2 $
 * --------------------------------------------------*/

typedef     SV *version;

MODULE = version	PACKAGE = version

PROTOTYPES: DISABLE
VERSIONCHECK: DISABLE

BOOT:
	/* register the overloading (type 'A') magic */
	PL_amagic_generation++;
	newXS("version::()", XS_version_noop, file);
	newXS("version::(\"\"", XS_version_stringify, file);
	newXS("version::(0+", XS_version_numify, file);
	newXS("version::(cmp", XS_version_vcmp, file);
	newXS("version::(<=>", XS_version_vcmp, file);
	newXS("version::(bool", XS_version_boolean, file);
	newXS("version::(nomethod", XS_version_noop, file);
/*	newXS("UNIVERSAL::VERSION", XS_version_VERSION, file); */

version
new(class,vs)
    char *class
    SV *vs
PPCODE:
{
    PUSHs(new_version(vs));
}

void
stringify (lobj,...)
    version		lobj
PPCODE:
{
    SV  *vs = NEWSV(92,5);
    if ( lobj == SvRV(PL_patchlevel) )
	sv_setsv(vs,lobj);
    else
	vstringify(vs,lobj);
    PUSHs(vs);
}

void
numify (lobj,...)
    version		lobj
PPCODE:
{
    SV  *vs = NEWSV(92,5);
    vnumify(vs,lobj);
    PUSHs(vs);
}

void
vcmp (lobj,...)
    version		lobj
PPCODE:
{
    SV	*rs;
    SV	*rvs;
    SV * robj = ST(1);
    IV	 swap = (IV)SvIV(ST(2));

    if ( ! sv_derived_from(robj, "version") )
    {
	robj = new_version(robj);
    }
    rvs = SvRV(robj);

    if ( swap )
    {
        rs = newSViv(vcmp(rvs,lobj));
    }
    else
    {
        rs = newSViv(vcmp(lobj,rvs));
    }

    PUSHs(rs);
}

void
boolean(lobj,...)
    version		lobj
PPCODE:
{
    SV	*rs;
    rs = newSViv(sv_cmp(lobj,Nullsv));
    PUSHs(rs);
}

void
noop(lobj,...)
    version		lobj
CODE:
{
    croak("operation not supported with version object");
}
