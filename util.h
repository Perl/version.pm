#define PERL_MAGIC_vstring         'V' /* SV was vstring literal */
#define SvVOK(sv)          (SvMAGICAL(sv) && mg_find(sv,'V'))
char * scan_version(pTHX_ char *s, SV *rv);
SV * new_version(pTHX_ SV *ver);
SV * upg_version(pTHX_ SV *sv);
SV * vnumify(pTHX_ SV *sv, SV *vs);
SV * vstringify(pTHX_ SV *sv, SV *vs);
int vcmp(pTHX_ AV *lsv, AV *rsv);
