#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "util.h"

char *
scan_vstring(pTHX_ char *s, SV *av)
{
    char *pos = s;
    char *start = s;
    if (*pos == 'v') pos++;  /* get past 'v' */
    while (isDIGIT(*pos) || *pos == '_')
    pos++;
    if (!isALPHA(*pos)) {
	UV rev;
	U8 tmpbuf[UTF8_MAXLEN+1];
	U8 *tmpend;

	if (*s == 'v') s++;  /* get past 'v' */

	if ( SvTYPE(av) != SVt_PVAV )
	    SvUPGRADE(av, SVt_PVAV);

	for (;;) {
	    rev = 0;
	    {
		/* this is atoi() that tolerates underscores */
		char *end = pos;
		UV mult = 1;
		while (--end >= s) {
		    UV orev;
		    if (*end == '_')
			continue;
		    orev = rev;
		    rev += (*end - '0') * mult;
		    mult *= 10;
/*		    if (orev > rev && ckWARN_d(WARN_OVERFLOW))
			Perl_warner(aTHX_ packWARN(WARN_OVERFLOW),
				    "Integer overflow in decimal number"); */
		}
	    }

	    /* Append revision */
	    av_push( (AV *)av, newSViv(rev));
	    if (*pos == '.' && isDIGIT(pos[1]))
		 s = ++pos;
	    else {
		 s = pos;
		 break;
	    }
	    while (isDIGIT(*pos) || *pos == '_')
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
scan_version(pTHX_ char *version, SV *rv)
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
    version = scan_vstring(version, sv); /* store the v-string in the object */
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
    Perl_sv_setpvf(aTHX_ sv,"%d.",digit);
    for ( i = 1 ; i <= len ; i++ )
    {
	digit = SvIVX(*av_fetch((AV *)vs, i, 0));
	Perl_sv_catpvf(aTHX_ sv,"%03d",digit);
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

