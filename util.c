#include "util.h"

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
Perl_scan_version(pTHX_ char *s, SV *rv)
{
    const char *start = s;
    char *pos = s;
    I32 saw_period = 0;
    bool saw_under = 0;
    SV* sv = newSVrv(rv, "version"); /* create an SV and upgrade the RV */
    (void)sv_upgrade(sv, SVt_PVAV); /* needs to be an AV type */

    /* pre-scan the imput string to check for decimals */
    while ( *pos == '.' || *pos == '_' || isDIGIT(*pos) )
    {
	if ( *pos == '.' )
	{
	    if ( saw_under )
		Perl_croak(aTHX_ "Invalid version format (underscores before decimal)");
	    saw_period++ ;
	}
	else if ( *pos == '_' )
	{
	    if ( saw_under )
		Perl_croak(aTHX_ "Invalid version format (multiple underscores)");
	    saw_under = 1;
	}
	pos++;
    }
    pos = s;

    if (*pos == 'v') pos++;  /* get past 'v' */
    while (isDIGIT(*pos))
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
 		I32 orev;
  		if ( s < pos && s > start && *(s-1) == '_' ) {
 			mult *= -1;	/* beta version */
  		}
		/* the following if() will only be true after the decimal
		 * point of a version originally created with a bare
		 * floating point number, i.e. not quoted in any way
		 */
 		if ( s > start+1 && saw_period == 1 && !saw_under ) {
 		    mult = 100;
 		    while ( s < end ) {
 			orev = rev;
 			rev += (*s - '0') * mult;
 			mult /= 10;
 			if ( abs(orev) > abs(rev) )
 			    Perl_croak(aTHX_ "Integer overflow in version");
 			s++;
 		    }
  		}
 		else {
 		    while (--end >= s) {
 			orev = rev;
 			rev += (*end - '0') * mult;
 			mult *= 10;
 			if ( abs(orev) > abs(rev) )
 			    Perl_croak(aTHX_ "Integer overflow in version");
 		    }
 		} 
  	    }
  
  	    /* Append revision */
	    av_push((AV *)sv, newSViv(rev));
	    if ( (*pos == '.' || *pos == '_') && isDIGIT(pos[1]))
		s = ++pos;
	    else if ( isDIGIT(*pos) )
		s = pos;
	    else {
		s = pos;
		break;
	    }
	    while ( isDIGIT(*pos) ) {
		if ( !saw_under && saw_period == 1 && pos-s == 3 )
		    break;
		pos++;
	    }
	}
    }
    return s;
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
Perl_new_version(pTHX_ SV *ver)
{
    SV *rv = newSV(0);
    char *version;
    if ( SvNOK(ver) ) /* may get too much accuracy */ 
    {
	char tbuf[64];
	sprintf(tbuf,"%.9"NVgf, SvNVX(ver));
	version = savepv(tbuf);
    }
#ifdef SvVOK
    else if ( SvVOK(ver) ) { /* already a v-string */
	MAGIC* mg = mg_find(ver,PERL_MAGIC_vstring);
	version = savepvn( (const char*)mg->mg_ptr,mg->mg_len );
    }
#endif
    else /* must be a string or something like a string */
    {
	version = (char *)SvPV(ver,PL_na);
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
Perl_upg_version(pTHX_ SV *ver)
{
    char *version = savepvn(SvPVX(ver),SvCUR(ver));
#ifdef SvVOK
    if ( SvVOK(ver) ) { /* already a v-string */
	MAGIC* mg = mg_find(ver,PERL_MAGIC_vstring);
	version = savepvn( (const char*)mg->mg_ptr,mg->mg_len );
    }
#endif
    version = scan_version(version,ver);
    return ver;
}


/*
=for apidoc vnumify

Accepts a version object and returns the normalized floating
point representation.  Call like:

    sv = vnumify(rv);

NOTE: you can pass either the object directly or the SV
contained within the RV.

=cut
*/

SV *
Perl_vnumify(pTHX_ SV *vs)
{
    I32 i, len, digit;
    SV *sv = NEWSV(92,0);
    if ( SvROK(vs) )
	vs = SvRV(vs);
    len = av_len((AV *)vs);
    if ( len == -1 )
    {
	Perl_sv_catpv(aTHX_ sv,"0");
	return sv;
    }
    digit = SvIVX(*av_fetch((AV *)vs, 0, 0));
    Perl_sv_setpvf(aTHX_ sv,"%d.",abs(digit));
    for ( i = 1 ; i <= len ; i++ )
    {
	digit = SvIVX(*av_fetch((AV *)vs, i, 0));
	Perl_sv_catpvf(aTHX_ sv,"%03d",abs(digit));
    }
    if ( len == 0 )
	 Perl_sv_catpv(aTHX_ sv,"000");
    sv_setnv(sv, SvNV(sv));
    return sv;
}

/*
=for apidoc vstringify

Accepts a version object and returns the normalized string
representation.  Call like:

    sv = vstringify(rv);

NOTE: you can pass either the object directly or the SV
contained within the RV.

=cut
*/

SV *
Perl_vstringify(pTHX_ SV *vs)
{
    I32 i, len, digit;
    SV *sv = NEWSV(92,0);
    if ( SvROK(vs) )
	vs = SvRV(vs);
    len = av_len((AV *)vs);
    if ( len == -1 )
    {
	Perl_sv_catpv(aTHX_ sv,"");
	return sv;
    }
    digit = SvIVX(*av_fetch((AV *)vs, 0, 0));
    Perl_sv_setpvf(aTHX_ sv,"%d",digit);
    for ( i = 1 ; i <= len ; i++ )
    {
	digit = SvIVX(*av_fetch((AV *)vs, i, 0));
	if ( digit < 0 )
	    Perl_sv_catpvf(aTHX_ sv,"_%d",-digit);
	else
	    Perl_sv_catpvf(aTHX_ sv,".%d",digit);
    }
    if ( len == 0 )
	 Perl_sv_catpv(aTHX_ sv,".0");
    return sv;
} 

/*
=for apidoc vcmp

Version object aware cmp.  Both operands must already have been 
converted into version objects.

=cut
*/

int
Perl_vcmp(pTHX_ SV *lsv, SV *rsv)
{
    I32 i,l,m,r,retval;
    if ( SvROK(lsv) )
	lsv = SvRV(lsv);
    if ( SvROK(rsv) )
	rsv = SvRV(rsv);
    l = av_len((AV *)lsv);
    r = av_len((AV *)rsv);
    m = l < r ? l : r;
    retval = 0;
    i = 0;
    while ( i <= m && retval == 0 )
    {
	I32 left  = SvIV(*av_fetch((AV *)lsv,i,0));
	I32 right = SvIV(*av_fetch((AV *)rsv,i,0));
	bool lbeta = left  < 0 ? 1 : 0;
	bool rbeta = right < 0 ? 1 : 0;
	left  = abs(left);
	right = abs(right);
	if ( left < right || (left == right && lbeta && !rbeta) )
	    retval = -1;
	if ( left > right || (left == right && rbeta && !lbeta) )
	    retval = +1;
	i++;
    }

    if ( l != r && retval == 0 ) /* possible match except for trailing 0 */
    {
	if ( !( l < r && r-l == 1 && SvIV(*av_fetch((AV *)rsv,r,0)) == 0 ) &&
	     !( l-r == 1 && SvIV(*av_fetch((AV *)lsv,l,0)) == 0 ) )
	{
	    retval = l < r ? -1 : +1; /* not a match after all */
	}
    }
    return retval;
}
