:: configuration
@prompt $g$s &:: minimize output "noise"
@echo ON

set "DIST_SUPPRESS_DEPS=1"

if /I "%Perl_VERSION%" == "5.8.9" ( set "DIST_EXTRA_DEPS=parent" )
if /I "%Perl_VERSION%" == "5.8.8" ( set "DIST_EXTRA_DEPS=parent" )
if /I "%Perl_VERSION%" == "5.8"   ( set "DIST_EXTRA_DEPS=parent" )

set  DEVEL_COVER_OPTIONS=-ignore,^^^^t/,^^^^t.*\.pm$,/vpp\.pm$,/vxs\.pm$

@echo OFF
@echo.
