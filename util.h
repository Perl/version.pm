#ifndef pTHX_
  #define pTHX_
#endif
#ifndef aTHX_
  #define aTHX_
#endif
#ifndef WARN_OVERFLOW
  #define WARN_OVERFLOW ("WARNING")
#endif
char * scan_version(pTHX_ char *s, SV *rv);
SV * new_version(pTHX_ SV *ver);
SV * upg_version(pTHX_ SV *sv);
SV * vnumify(pTHX_ SV *sv, SV *vs);
SV * vstringify(pTHX_ SV *sv, SV *vs);
int vcmp(pTHX_ SV *lsv, SV *rsv);
