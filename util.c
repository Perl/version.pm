#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "util.h"

char *
scan_version(pTHX_ char *s, SV *rv)
{
    char *pos = s;
    char *start = s;
    AV* av = (AV *)newSVrv(rv, "version"); /* create an SV and upgrade the RV */
    if ( SvTYPE(av) != SVt_PVAV )	/* it's not really an AV yet */
	SvUPGRADE((SV *)av, SVt_PVAV);

    if (*pos == 'v') pos++;  /* get past 'v' */
    while (isDIGIT(*pos) || *pos == '_')
    pos++;
    if (!isALPHA(*pos)) {
	I32 rev;

	if (*s == 'v') s++;  /* get past 'v' */

	for (;;) {
	    rev = 0;
	    {
		/* this is atoi() that delimits on underscores */
		char *end = pos;
		I32 mult = 1;
		if ( s < pos && *(s-1) == '_' ) {
		    if ( *s == '0' )
			mult = 10;	/* perl-style */
		    else
			mult = -1;	/* beta version */
		}
		while (--end >= s) {

		    I32 orev;
		    orev = rev;
		    rev += (*end - '0') * mult;
		    mult *= 10;
/*		    if (orev > rev && ckWARN_d(WARN_OVERFLOW))
			Perl_warner(aTHX_ packWARN(WARN_OVERFLOW),
				    "Integer overflow in decimal number"); */
		}
	    }

	    /* Append revision */
	    av_push(av, newSViv(rev));
	    if ( (*pos == '.' || *pos == '_') && isDIGIT(pos[1]))
		 s = ++pos;
	    else {
		 s = pos;
		 break;
	    }
	    while ( isDIGIT(*pos) )
		 pos++;
	}
    }
    return s;
}

/*
=for apidoc scan_version

Returns a pointer to the next character after the parsed
version string, as well as upgrading the passed in SV to
an RV.

Function must be called with an already existing SV like

    sv = NEWSV(92,0);
    s = scan_version(s,sv);

Performs some preprocessing to the string to ensure that
it has the correct characteristics of a version.  Flags the
object if it contains an underscore (which denotes this
is a beta version).

=cut
*/

char *
scan_version2(pTHX_ char *version, SV *rv)
{
    char* d;
    int beta = 0;
    SV* sv = newSVrv(rv, "version"); /* create an SV and upgrade the RV */
    d = version;
    if (*d == 'v')
	d++;
    if (isDIGIT(*d)) {
	while (isDIGIT(*d) || *d == '.' || *d == '\0')
	    d++;
	if (*d == '_') {
	    *d = '.';
	    if (*(d+1) == '0' && *(d+2) != '0') { /* perl-style version */
		*(d+1) = *(d+2);
		*(d+2) = '0';
/*		if (ckWARN(WARN_PORTABLE))
		    Perl_warner(aTHX_ packWARN(WARN_PORTABLE),
				"perl-style version not portable"); */
	    }
	    else {
		beta = -1;
	    }
	}
	while (isDIGIT(*d) || *d == '.' || *d == '\0')
	    d++;
	if (*d == '_')
	    Perl_croak(aTHX_ "Invalid version format (multiple underscores)");
    }
/*    version = scan_vstring(version, sv);*/ /* store the v-string in the object */
    if ( beta < 0 )
    {
	SV *last = (SV *)av_fetch((AV *)sv,av_len((AV *)sv),0);
	SvIVX(last) *= -1;
	av_store((AV *)sv,av_len((AV *)sv),last);
    }
    return version;
}

/*
=for apidoc new_version

Returns a new version object based on the passed in SV:

    SV *sv = new_version(SV *ver);

Does not alter the passed in ver SV.  See "upg_version" if you
want to upgrade the SV.

=cut
*/

SV *
new_version(pTHX_ SV *ver)
{
    SV *rv = NEWSV(92,5);
    char *version;

    if ( SvMAGICAL(ver) ) { /* already a v-string */
	MAGIC* mg = mg_find(ver,PERL_MAGIC_vstring);
	version = savepvn( (const char*)mg->mg_ptr,mg->mg_len );
    }
    else {
	version = (char *)SvPV_nolen(ver);
    }
    version = scan_version(version,rv);
    return rv;
}

/*
=for apidoc upg_version

In-place upgrade of the supplied SV to a version object.

    SV *sv = upg_version(SV *sv);

Returns a pointer to the upgraded SV.

=cut
*/

SV *
upg_version(pTHX_ SV *sv)
{
    char *version = (char *)SvPV_nolen(sv_mortalcopy(sv));
    if ( SvVOK(sv) ) { /* already a v-string */
	SV * ver = newSVrv(sv, "version");
	sv_setpv(ver,version);
    }
    else {
	version = scan_version(version,sv);
    }
    return sv;
}


/*
=for apidoc vnumify

Accepts a version (or vstring) object and returns the
normalized floating point representation.  Call like:

    sv = vnumify(sv,SvRV(rv));

NOTE: no checking is done to see if the object is of the
correct type (for speed).

=cut
*/

SV *
vnumify(pTHX_ SV *sv, SV *vs)
{
    I32 i;
    I32 len = av_len((AV *)vs);
    I32 digit = SvIVX(*av_fetch((AV *)vs, 0, 0));
    Perl_sv_setpvf(aTHX_ sv,"%d.",abs(digit));
    for ( i = 1 ; i <= len ; i++ )
    {
	digit = SvIVX(*av_fetch((AV *)vs, i, 0));
	Perl_sv_catpvf(aTHX_ sv,"%03d",abs(digit));
    }
    return sv;
}

/*
=for apidoc vstringify

Accepts a version (or vstring) object and returns the
normalized representation.  Call like:

    sv = vstringify(sv,SvRV(rv));

NOTE: no checking is done to see if the object is of the
correct type (for speed).

=cut
*/

SV *
vstringify(pTHX_ SV *sv, SV *vs)
{
    I32 i;
    I32 len = av_len((AV *)vs);
    I32 digit = SvIVX(*av_fetch((AV *)vs, 0, 0));
    Perl_sv_setpvf(aTHX_ sv,"%d",digit);
    for ( i = 1 ; i <= len ; i++ )
    {
	digit = SvIVX(*av_fetch((AV *)vs, i, 0));
	if ( digit < 0 )
	    Perl_sv_catpvf(aTHX_ sv,"_%d",-digit);
	else
	    Perl_sv_catpvf(aTHX_ sv,".%d",digit);
    }
    return sv;
} 

/*
=for apidoc vcmp

Version object aware cmp

=cut
*/

int
vcmp(pTHX_ AV *lsv, AV *rsv)
{
    I32 l = av_len(lsv);
    I32 r = av_len(rsv);
    I32 m = l < r ? l : r;
    I32 retval = 0;
    I32 i = 0;
    while ( i <= m && retval == 0 )
    {
	I32 left  = abs( SvIV((SV *)av_fetch(lsv,i,0)) );
	I32 right = abs( SvIV((SV *)av_fetch(rsv,i,0)) );
	if ( left < right )
	    retval = -1;
	if ( left > right )
	    retval = +1;
	i++;
    }

    if ( l != r && retval == 0 )
	retval = l < r ? -1 : +1;
    return retval;
}


