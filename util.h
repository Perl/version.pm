#define PERL_MAGIC_vstring         'V' /* SV was vstring literal */
#define SvVOK(sv)          (SvMAGICAL(sv) && mg_find(sv,'V'))

