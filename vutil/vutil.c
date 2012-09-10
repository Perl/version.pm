#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#define NEED_my_snprintf
#define NEED_newRV_noinc
#define NEED_vnewSVpvf
#define NEED_newSVpvn_flags_GLOBAL
#define NEED_warner
#include "ppport.h"
#include "vutil.h"

#define VERSION_MAX 0x7FFFFFFF

/*
=for apidoc prescan_version

Validate that a given string can be parsed as a version object, but doesn't
actually perform the parsing.  Can use either strict or lax validation rules.
Can optionally set a number of hint variables to save the parsing code
some time when tokenizing.

=cut
*/
const char *
#if VUTIL_REPLACE_CORE
Perl_prescan_version2(pTHX_ const char *s, bool strict,
#else
Perl_prescan_version(pTHX_ const char *s, bool strict,
#endif
		     const char **errstr,
		     bool *sqv, int *ssaw_decimal, int *swidth, bool *salpha) {
    bool qv = (sqv ? *sqv : FALSE);
    int width = 3;
    int saw_decimal = 0;
    bool alpha = FALSE;
    const char *d = s;

    PERL_ARGS_ASSERT_PRESCAN_VERSION;

    if (qv && isDIGIT(*d))
	goto dotted_decimal_version;

    if (*d == 'v') { /* explicit v-string */
	d++;
	if (isDIGIT(*d)) {
	    qv = TRUE;
	}
	else { /* degenerate v-string */
	    /* requires v1.2.3 */
	    BADVERSION(s,errstr,"Invalid version format (dotted-decimal versions require at least three parts)");
	}

dotted_decimal_version:
	if (strict && d[0] == '0' && isDIGIT(d[1])) {
	    /* no leading zeros allowed */
	    BADVERSION(s,errstr,"Invalid version format (no leading zeros)");
	}

	while (isDIGIT(*d)) 	/* integer part */
	    d++;

	if (*d == '.')
	{
	    saw_decimal++;
	    d++; 		/* decimal point */
	}
	else
	{
	    if (strict) {
		/* require v1.2.3 */
		BADVERSION(s,errstr,"Invalid version format (dotted-decimal versions require at least three parts)");
	    }
	    else {
		goto version_prescan_finish;
	    }
	}

	{
	    int i = 0;
	    int j = 0;
	    while (isDIGIT(*d)) {	/* just keep reading */
		i++;
		while (isDIGIT(*d)) {
		    d++; j++;
		    /* maximum 3 digits between decimal */
		    if (strict && j > 3) {
			BADVERSION(s,errstr,"Invalid version format (maximum 3 digits between decimals)");
		    }
		}
		if (*d == '_') {
		    if (strict) {
			BADVERSION(s,errstr,"Invalid version format (no underscores)");
		    }
		    if ( alpha ) {
			BADVERSION(s,errstr,"Invalid version format (multiple underscores)");
		    }
		    d++;
		    alpha = TRUE;
		}
		else if (*d == '.') {
		    if (alpha) {
			BADVERSION(s,errstr,"Invalid version format (underscores before decimal)");
		    }
		    saw_decimal++;
		    d++;
		}
		else if (!isDIGIT(*d)) {
		    break;
		}
		j = 0;
	    }

	    if (strict && i < 2) {
		/* requires v1.2.3 */
		BADVERSION(s,errstr,"Invalid version format (dotted-decimal versions require at least three parts)");
	    }
	}
    } 					/* end if dotted-decimal */
    else
    {					/* decimal versions */
	int j = 0;			/* may need this later */
	/* special strict case for leading '.' or '0' */
	if (strict) {
	    if (*d == '.') {
		BADVERSION(s,errstr,"Invalid version format (0 before decimal required)");
	    }
	    if (*d == '0' && isDIGIT(d[1])) {
		BADVERSION(s,errstr,"Invalid version format (no leading zeros)");
	    }
	}

	/* and we never support negative versions */
	if ( *d == '-') {
	    BADVERSION(s,errstr,"Invalid version format (negative version number)");
	}

	/* consume all of the integer part */
	while (isDIGIT(*d))
	    d++;

	/* look for a fractional part */
	if (*d == '.') {
	    /* we found it, so consume it */
	    saw_decimal++;
	    d++;
	}
	else if (!*d || *d == ';' || isSPACE(*d) || *d == '{' || *d == '}') {
	    if ( d == s ) {
		/* found nothing */
		BADVERSION(s,errstr,"Invalid version format (version required)");
	    }
	    /* found just an integer */
	    goto version_prescan_finish;
	}
	else if ( d == s ) {
	    /* didn't find either integer or period */
	    BADVERSION(s,errstr,"Invalid version format (non-numeric data)");
	}
	else if (*d == '_') {
	    /* underscore can't come after integer part */
	    if (strict) {
		BADVERSION(s,errstr,"Invalid version format (no underscores)");
	    }
	    else if (isDIGIT(d[1])) {
		BADVERSION(s,errstr,"Invalid version format (alpha without decimal)");
	    }
	    else {
		BADVERSION(s,errstr,"Invalid version format (misplaced underscore)");
	    }
	}
	else {
	    /* anything else after integer part is just invalid data */
	    BADVERSION(s,errstr,"Invalid version format (non-numeric data)");
	}

	/* scan the fractional part after the decimal point*/

	if (!isDIGIT(*d) && (strict || ! (!*d || *d == ';' || isSPACE(*d) || *d == '{' || *d == '}') )) {
		/* strict or lax-but-not-the-end */
		BADVERSION(s,errstr,"Invalid version format (fractional part required)");
	}

	while (isDIGIT(*d)) {
	    d++; j++;
	    if (*d == '.' && isDIGIT(d[-1])) {
		if (alpha) {
		    BADVERSION(s,errstr,"Invalid version format (underscores before decimal)");
		}
		if (strict) {
		    BADVERSION(s,errstr,"Invalid version format (dotted-decimal versions must begin with 'v')");
		}
		d = (char *)s; 		/* start all over again */
		qv = TRUE;
		goto dotted_decimal_version;
	    }
	    if (*d == '_') {
		if (strict) {
		    BADVERSION(s,errstr,"Invalid version format (no underscores)");
		}
		if ( alpha ) {
		    BADVERSION(s,errstr,"Invalid version format (multiple underscores)");
		}
		if ( ! isDIGIT(d[1]) ) {
		    BADVERSION(s,errstr,"Invalid version format (misplaced underscore)");
		}
		width = j;
		d++;
		alpha = TRUE;
	    }
	}
    }

version_prescan_finish:
    while (isSPACE(*d))
	d++;

    if (!isDIGIT(*d) && (! (!*d || *d == ';' || *d == '{' || *d == '}') )) {
	/* trailing non-numeric data */
	BADVERSION(s,errstr,"Invalid version format (non-numeric data)");
    }

    if (sqv)
	*sqv = qv;
    if (swidth)
	*swidth = width;
    if (ssaw_decimal)
	*ssaw_decimal = saw_decimal;
    if (salpha)
	*salpha = alpha;
    return d;
}

/*
=for apidoc scan_version

Returns a pointer to the next character after the parsed
version string, as well as upgrading the passed in SV to
an RV.

Function must be called with an already existing SV like

    sv = newSV(0);
    s = scan_version(s, SV *sv, bool qv);

Performs some preprocessing to the string to ensure that
it has the correct characteristics of a version.  Flags the
object if it contains an underscore (which denotes this
is an alpha version).  The boolean qv denotes that the version
should be interpreted as if it had multiple decimals, even if
it doesn't.

=cut
*/

const char *
#if VUTIL_REPLACE_CORE
Perl_scan_version2(pTHX_ const char *s, SV *rv, bool qv)
#else
Perl_scan_version(pTHX_ const char *s, SV *rv, bool qv)
#endif
{
    const char *start;
    const char *pos;
    const char *last;
    const char *errstr = NULL;
    int saw_decimal = 0;
    int width = 3;
    bool alpha = FALSE;
    bool vinf = FALSE;
    AV * const av = newAV();
    SV * const hv = newSVrv(rv, "version"); /* create an SV and upgrade the RV */

    PERL_ARGS_ASSERT_SCAN_VERSION;

    (void)sv_upgrade(hv, SVt_PVHV); /* needs to be an HV type */

#ifndef NODEFAULT_SHAREKEYS
    HvSHAREKEYS_on(hv);         /* key-sharing on by default */
#endif

    while (isSPACE(*s)) /* leading whitespace is OK */
	s++;

    last = PRESCAN_VERSION(s, FALSE, &errstr, &qv, &saw_decimal, &width, &alpha);
    if (errstr) {
	/* "undef" is a special case and not an error */
	if ( ! ( *s == 'u' && strEQ(s,"undef")) ) {
	    Perl_croak(aTHX_ "%s", errstr);
	}
    }

    start = s;
    if (*s == 'v')
	s++;
    pos = s;

    if ( qv )
	(void)hv_stores(MUTABLE_HV(hv), "qv", newSViv(qv));
    if ( alpha )
	(void)hv_stores(MUTABLE_HV(hv), "alpha", newSViv(alpha));
    if ( !qv && width < 3 )
	(void)hv_stores(MUTABLE_HV(hv), "width", newSViv(width));

    while (isDIGIT(*pos))
	pos++;
    if (!isALPHA(*pos)) {
	I32 rev;

	for (;;) {
	    rev = 0;
	    {
  		/* this is atoi() that delimits on underscores */
  		const char *end = pos;
  		I32 mult = 1;
		I32 orev;

		/* the following if() will only be true after the decimal
		 * point of a version originally created with a bare
		 * floating point number, i.e. not quoted in any way
		 */
		if ( !qv && s > start && saw_decimal == 1 ) {
		    mult *= 100;
 		    while ( s < end ) {
			orev = rev;
 			rev += (*s - '0') * mult;
 			mult /= 10;
			if (   (PERL_ABS(orev) > PERL_ABS(rev)) 
			    || (PERL_ABS(rev) > VERSION_MAX )) {
			    Perl_ck_warner(aTHX_ packWARN(WARN_OVERFLOW), 
					   "Integer overflow in version %d",VERSION_MAX);
			    s = end - 1;
			    rev = VERSION_MAX;
			    vinf = 1;
			}
 			s++;
			if ( *s == '_' )
			    s++;
 		    }
  		}
 		else {
 		    while (--end >= s) {
			orev = rev;
 			rev += (*end - '0') * mult;
 			mult *= 10;
			if (   (PERL_ABS(orev) > PERL_ABS(rev)) 
			    || (PERL_ABS(rev) > VERSION_MAX )) {
			    Perl_ck_warner(aTHX_ packWARN(WARN_OVERFLOW), 
					   "Integer overflow in version");
			    end = s - 1;
			    rev = VERSION_MAX;
			    vinf = 1;
			}
 		    }
 		} 
  	    }

  	    /* Append revision */
	    av_push(av, newSViv(rev));
	    if ( vinf ) {
		s = last;
		break;
	    }
	    else if ( *pos == '.' )
		s = ++pos;
	    else if ( *pos == '_' && isDIGIT(pos[1]) )
		s = ++pos;
	    else if ( *pos == ',' && isDIGIT(pos[1]) )
		s = ++pos;
	    else if ( isDIGIT(*pos) )
		s = pos;
	    else {
		s = pos;
		break;
	    }
	    if ( qv ) {
		while ( isDIGIT(*pos) )
		    pos++;
	    }
	    else {
		int digits = 0;
		while ( ( isDIGIT(*pos) || *pos == '_' ) && digits < 3 ) {
		    if ( *pos != '_' )
			digits++;
		    pos++;
		}
	    }
	}
    }
    if ( qv ) { /* quoted versions always get at least three terms*/
	I32 len = av_len(av);
	/* This for loop appears to trigger a compiler bug on OS X, as it
	   loops infinitely. Yes, len is negative. No, it makes no sense.
	   Compiler in question is:
	   gcc version 3.3 20030304 (Apple Computer, Inc. build 1640)
	   for ( len = 2 - len; len > 0; len-- )
	   av_push(MUTABLE_AV(sv), newSViv(0));
	*/
	len = 2 - len;
	while (len-- > 0)
	    av_push(av, newSViv(0));
    }

    /* need to save off the current version string for later */
    if ( vinf ) {
	SV * orig = newSVpvn("v.Inf", sizeof("v.Inf")-1);
	(void)hv_stores(MUTABLE_HV(hv), "original", orig);
	(void)hv_stores(MUTABLE_HV(hv), "vinf", newSViv(1));
    }
    else if ( s > start ) {
	SV * orig = newSVpvn(start,s-start);
	if ( qv && saw_decimal == 1 && *start != 'v' ) {
	    /* need to insert a v to be consistent */
	    sv_insert(orig, 0, 0, "v", 1);
	}
	(void)hv_stores(MUTABLE_HV(hv), "original", orig);
    }
    else {
	(void)hv_stores(MUTABLE_HV(hv), "original", newSVpvs("0"));
	av_push(av, newSViv(0));
    }

    /* And finally, store the AV in the hash */
    (void)hv_stores(MUTABLE_HV(hv), "version", newRV_noinc(MUTABLE_SV(av)));

    /* fix RT#19517 - special case 'undef' as string */
    if ( *s == 'u' && strEQ(s,"undef") ) {
	s += 5;
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
#if VUTIL_REPLACE_CORE
Perl_new_version2(pTHX_ SV *ver)
#else
Perl_new_version(pTHX_ SV *ver)
#endif
{
    dVAR;
    SV * const rv = newSV(0);
    PERL_ARGS_ASSERT_NEW_VERSION;
    if ( ISA_CLASS_OBJ(ver,"version") ) /* can just copy directly */
    {
	I32 key;
	AV * const av = newAV();
	AV *sav;
	/* This will get reblessed later if a derived class*/
	SV * const hv = newSVrv(rv, "version"); 
	(void)sv_upgrade(hv, SVt_PVHV); /* needs to be an HV type */
#ifndef NODEFAULT_SHAREKEYS
	HvSHAREKEYS_on(hv);         /* key-sharing on by default */
#endif

	if ( SvROK(ver) )
	    ver = SvRV(ver);

	/* Begin copying all of the elements */
	if ( hv_exists(MUTABLE_HV(ver), "qv", 2) )
	    (void)hv_stores(MUTABLE_HV(hv), "qv", newSViv(1));

	if ( hv_exists(MUTABLE_HV(ver), "alpha", 5) )
	    (void)hv_stores(MUTABLE_HV(hv), "alpha", newSViv(1));

	if ( hv_exists(MUTABLE_HV(ver), "width", 5 ) )
	{
	    const I32 width = SvIV(*hv_fetchs(MUTABLE_HV(ver), "width", FALSE));
	    (void)hv_stores(MUTABLE_HV(hv), "width", newSViv(width));
	}

	if ( hv_exists(MUTABLE_HV(ver), "original", 8 ) )
	{
	    SV * pv = *hv_fetchs(MUTABLE_HV(ver), "original", FALSE);
	    (void)hv_stores(MUTABLE_HV(hv), "original", newSVsv(pv));
	}

	sav = MUTABLE_AV(SvRV(*hv_fetchs(MUTABLE_HV(ver), "version", FALSE)));
	/* This will get reblessed later if a derived class*/
	for ( key = 0; key <= av_len(sav); key++ )
	{
	    const I32 rev = SvIV(*av_fetch(sav, key, FALSE));
	    av_push(av, newSViv(rev));
	}

	(void)hv_stores(MUTABLE_HV(hv), "version", newRV_noinc(MUTABLE_SV(av)));
	return rv;
    }
#ifdef SvVOK
    {
	const MAGIC* const mg = SvVSTRING_mg(ver);
	if ( mg ) { /* already a v-string */
	    const STRLEN len = mg->mg_len;
	    char * const version = savepvn( (const char*)mg->mg_ptr, len);
	    sv_setpvn(rv,version,len);
	    /* this is for consistency with the pure Perl class */
	    if ( isDIGIT(*version) )
		sv_insert(rv, 0, 0, "v", 1);
	    Safefree(version);
	}
	else {
#endif
	sv_setsv(rv,ver); /* make a duplicate */
#ifdef SvVOK
	}
    }
#endif
    return UPG_VERSION(rv, FALSE);
}

/*
=for apidoc upg_version

In-place upgrade of the supplied SV to a version object.

    SV *sv = upg_version(SV *sv, bool qv);

Returns a pointer to the upgraded SV.  Set the boolean qv if you want
to force this SV to be interpreted as an "extended" version.

=cut
*/

SV *
#if VUTIL_REPLACE_CORE
Perl_upg_version2(pTHX_ SV *ver, bool qv)
#else
Perl_upg_version(pTHX_ SV *ver, bool qv)
#endif
{
    const char *version, *s;
#ifdef SvVOK
    const MAGIC *mg;
#endif

    PERL_ARGS_ASSERT_UPG_VERSION;

    if ( SvNOK(ver) && !( SvPOK(ver) && sv_len(ver) == 3 ) )
    {
	STRLEN len;

	/* may get too much accuracy */ 
	char tbuf[64];
	SV *sv = SvNVX(ver) > 10e50 ? newSV(64) : 0;
	char *buf;
#ifdef USE_LOCALE_NUMERIC
	char *loc = savepv(setlocale(LC_NUMERIC, NULL));
	setlocale(LC_NUMERIC, "C");
#endif
	if (sv) {
	    Perl_sv_setpvf(aTHX_ sv, "%.9"NVff, SvNVX(ver));
	    buf = SvPV(sv, len);
	}
	else {
	    len = my_snprintf(tbuf, sizeof(tbuf), "%.9"NVff, SvNVX(ver));
	    buf = tbuf;
	}
#ifdef USE_LOCALE_NUMERIC
	setlocale(LC_NUMERIC, loc);
	Safefree(loc);
#endif
	while (buf[len-1] == '0' && len > 0) len--;
	if ( buf[len-1] == '.' ) len--; /* eat the trailing decimal */
	version = savepvn(buf, len);
	SvREFCNT_dec(sv);
    }
#ifdef SvVOK
    else if ( (mg = SvVSTRING_mg(ver)) ) { /* already a v-string */
	version = savepvn( (const char*)mg->mg_ptr,mg->mg_len );
	qv = TRUE;
    }
#endif
    else /* must be a string or something like a string */
    {
	STRLEN len;
	version = savepv(SvPV(ver,len));
#ifndef SvVOK
#  if PERL_VERSION > 5
	/* This will only be executed for 5.6.0 - 5.8.0 inclusive */
	if ( len >= 3 && !instr(version,".") && !instr(version,"_")) {
	    /* may be a v-string */
	    char *testv = (char *)version;
	    STRLEN tlen = len;
	    for (tlen=0; tlen < len; tlen++, testv++) {
		/* if one of the characters is non-text assume v-string */
		if (testv[0] < ' ') {
		    SV * const nsv = sv_newmortal();
		    const char *nver;
		    const char *pos;
		    int saw_decimal = 0;
		    sv_setpvf(nsv,"v%vd",ver);
		    pos = nver = savepv(SvPV_nolen(nsv));

		    /* scan the resulting formatted string */
		    pos++; /* skip the leading 'v' */
		    while ( *pos == '.' || isDIGIT(*pos) ) {
			if ( *pos == '.' )
			    saw_decimal++ ;
			pos++;
		    }

		    /* is definitely a v-string */
		    if ( saw_decimal >= 2 ) {
			Safefree(version);
			version = nver;
		    }
		    break;
		}
	    }
	}
#  endif
#endif
    }

    s = SCAN_VERSION(version, ver, qv);
    if ( *s != '\0' ) 
	Perl_ck_warner(aTHX_ packWARN(WARN_MISC), 
		       "Version string '%s' contains invalid data; "
		       "ignoring: '%s'", version, s);
    Safefree(version);
    return ver;
}

/*
=for apidoc vverify

Validates that the SV contains valid internal structure for a version object.
It may be passed either the version object (RV) or the hash itself (HV).  If
the structure is valid, it returns the HV.  If the structure is invalid,
it returns NULL.

    SV *hv = vverify(sv);

Note that it only confirms the bare minimum structure (so as not to get
confused by derived classes which may contain additional hash entries):

=over 4

=item * The SV is an HV or a reference to an HV

=item * The hash contains a "version" key

=item * The "version" key has a reference to an AV as its value

=back

=cut
*/

SV *
#if VUTIL_REPLACE_CORE
Perl_vverify2(pTHX_ SV *vs)
#else
Perl_vverify(pTHX_ SV *vs)
#endif
{
    SV *sv;

    PERL_ARGS_ASSERT_VVERIFY;

    if ( SvROK(vs) )
	vs = SvRV(vs);

    /* see if the appropriate elements exist */
    if ( SvTYPE(vs) == SVt_PVHV
	 && hv_exists(MUTABLE_HV(vs), "version", 7)
	 && (sv = SvRV(*hv_fetchs(MUTABLE_HV(vs), "version", FALSE)))
	 && SvTYPE(sv) == SVt_PVAV )
	return vs;
    else
	return NULL;
}

/*
=for apidoc vnumify

Accepts a version object and returns the normalized floating
point representation.  Call like:

    sv = vnumify(rv);

NOTE: you can pass either the object directly or the SV
contained within the RV.

The SV returned has a refcount of 1.

=cut
*/

SV *
#if VUTIL_REPLACE_CORE
Perl_vnumify2(pTHX_ SV *vs)
#else
Perl_vnumify(pTHX_ SV *vs)
#endif
{
    I32 i, len, digit;
    int width;
    bool alpha = FALSE;
    SV *sv;
    AV *av;

    PERL_ARGS_ASSERT_VNUMIFY;

    /* extract the HV from the object */
    vs = VVERIFY(vs);
    if ( ! vs )
	Perl_croak(aTHX_ "Invalid version object");

    /* see if various flags exist */
    if ( hv_exists(MUTABLE_HV(vs), "alpha", 5 ) )
	alpha = TRUE;
    if ( hv_exists(MUTABLE_HV(vs), "width", 5 ) )
	width = SvIV(*hv_fetchs(MUTABLE_HV(vs), "width", FALSE));
    else
	width = 3;


    /* attempt to retrieve the version array */
    if ( !(av = MUTABLE_AV(SvRV(*hv_fetchs(MUTABLE_HV(vs), "version", FALSE))) ) ) {
	return newSVpvs("0");
    }

    len = av_len(av);
    if ( len == -1 )
    {
	return newSVpvs("0");
    }

    digit = SvIV(*av_fetch(av, 0, 0));
    sv = Perl_newSVpvf(aTHX_ "%d.", (int)PERL_ABS(digit));
    for ( i = 1 ; i < len ; i++ )
    {
	digit = SvIV(*av_fetch(av, i, 0));
	if ( width < 3 ) {
	    const int denom = (width == 2 ? 10 : 100);
	    const div_t term = div((int)PERL_ABS(digit),denom);
	    Perl_sv_catpvf(aTHX_ sv, "%0*d_%d", width, term.quot, term.rem);
	}
	else {
	    Perl_sv_catpvf(aTHX_ sv, "%0*d", width, (int)digit);
	}
    }

    if ( len > 0 )
    {
	digit = SvIV(*av_fetch(av, len, 0));
	if ( alpha && width == 3 ) /* alpha version */
	    sv_catpvs(sv,"_");
	Perl_sv_catpvf(aTHX_ sv, "%0*d", width, (int)digit);
    }
    else /* len == 0 */
    {
	sv_catpvs(sv, "000");
    }
    return sv;
}

/*
=for apidoc vnormal

Accepts a version object and returns the normalized string
representation.  Call like:

    sv = vnormal(rv);

NOTE: you can pass either the object directly or the SV
contained within the RV.

The SV returned has a refcount of 1.

=cut
*/

SV *
#if VUTIL_REPLACE_CORE
Perl_vnormal2(pTHX_ SV *vs)
#else
Perl_vnormal(pTHX_ SV *vs)
#endif
{
    I32 i, len, digit;
    bool alpha = FALSE;
    SV *sv;
    AV *av;

    PERL_ARGS_ASSERT_VNORMAL;

    /* extract the HV from the object */
    vs = VVERIFY(vs);
    if ( ! vs )
	Perl_croak(aTHX_ "Invalid version object");

    if ( hv_exists(MUTABLE_HV(vs), "alpha", 5 ) )
	alpha = TRUE;
    av = MUTABLE_AV(SvRV(*hv_fetchs(MUTABLE_HV(vs), "version", FALSE)));

    len = av_len(av);
    if ( len == -1 )
    {
	return newSVpvs("");
    }
    digit = SvIV(*av_fetch(av, 0, 0));
    sv = Perl_newSVpvf(aTHX_ "v%"IVdf, (IV)digit);
    for ( i = 1 ; i < len ; i++ ) {
	digit = SvIV(*av_fetch(av, i, 0));
	Perl_sv_catpvf(aTHX_ sv, ".%"IVdf, (IV)digit);
    }

    if ( len > 0 )
    {
	/* handle last digit specially */
	digit = SvIV(*av_fetch(av, len, 0));
	if ( alpha )
	    Perl_sv_catpvf(aTHX_ sv, "_%"IVdf, (IV)digit);
	else
	    Perl_sv_catpvf(aTHX_ sv, ".%"IVdf, (IV)digit);
    }

    if ( len <= 2 ) { /* short version, must be at least three */
	for ( len = 2 - len; len != 0; len-- )
	    sv_catpvs(sv,".0");
    }
    return sv;
}

/*
=for apidoc vstringify

In order to maintain maximum compatibility with earlier versions
of Perl, this function will return either the floating point
notation or the multiple dotted notation, depending on whether
the original version contained 1 or more dots, respectively.

The SV returned has a refcount of 1.

=cut
*/

SV *
#if VUTIL_REPLACE_CORE
Perl_vstringify2(pTHX_ SV *vs)
#else
Perl_vstringify(pTHX_ SV *vs)
#endif
{
    PERL_ARGS_ASSERT_VSTRINGIFY;

    /* extract the HV from the object */
    vs = VVERIFY(vs);
    if ( ! vs )
	Perl_croak(aTHX_ "Invalid version object");

    if (hv_exists(MUTABLE_HV(vs), "original",  sizeof("original") - 1)) {
	SV *pv;
	pv = *hv_fetchs(MUTABLE_HV(vs), "original", FALSE);
	if ( SvPOK(pv) )
	    return newSVsv(pv);
	else
	    return &PL_sv_undef;
    }
    else {
	if ( hv_exists(MUTABLE_HV(vs), "qv", 2) )
	    return VNORMAL(vs);
	else
	    return VNUMIFY(vs);
    }
}

/*
=for apidoc vcmp

Version object aware cmp.  Both operands must already have been 
converted into version objects.

=cut
*/

int
#if VUTIL_REPLACE_CORE
Perl_vcmp2(pTHX_ SV *lhv, SV *rhv)
#else
Perl_vcmp(pTHX_ SV *lhv, SV *rhv)
#endif
{
    I32 i,l,m,r,retval;
    bool lalpha = FALSE;
    bool ralpha = FALSE;
    I32 left = 0;
    I32 right = 0;
    AV *lav, *rav;

    PERL_ARGS_ASSERT_VCMP;

    /* extract the HVs from the objects */
    lhv = VVERIFY(lhv);
    rhv = VVERIFY(rhv);
    if ( ! ( lhv && rhv ) )
	Perl_croak(aTHX_ "Invalid version object");

    /* get the left hand term */
    lav = MUTABLE_AV(SvRV(*hv_fetchs(MUTABLE_HV(lhv), "version", FALSE)));
    if ( hv_exists(MUTABLE_HV(lhv), "alpha", 5 ) )
	lalpha = TRUE;

    /* and the right hand term */
    rav = MUTABLE_AV(SvRV(*hv_fetchs(MUTABLE_HV(rhv), "version", FALSE)));
    if ( hv_exists(MUTABLE_HV(rhv), "alpha", 5 ) )
	ralpha = TRUE;

    l = av_len(lav);
    r = av_len(rav);
    m = l < r ? l : r;
    retval = 0;
    i = 0;
    while ( i <= m && retval == 0 )
    {
	left  = SvIV(*av_fetch(lav,i,0));
	right = SvIV(*av_fetch(rav,i,0));
	if ( left < right  )
	    retval = -1;
	if ( left > right )
	    retval = +1;
	i++;
    }

    /* tiebreaker for alpha with identical terms */
    if ( retval == 0 && l == r && left == right && ( lalpha || ralpha ) )
    {
	if ( lalpha && !ralpha )
	{
	    retval = -1;
	}
	else if ( ralpha && !lalpha)
	{
	    retval = +1;
	}
    }

    if ( l != r && retval == 0 ) /* possible match except for trailing 0's */
    {
	if ( l < r )
	{
	    while ( i <= r && retval == 0 )
	    {
		if ( SvIV(*av_fetch(rav,i,0)) != 0 )
		    retval = -1; /* not a match after all */
		i++;
	    }
	}
	else
	{
	    while ( i <= l && retval == 0 )
	    {
		if ( SvIV(*av_fetch(lav,i,0)) != 0 )
		    retval = +1; /* not a match after all */
		i++;
	    }
	}
    }
    return retval;
}
