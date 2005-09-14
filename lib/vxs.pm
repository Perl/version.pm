#!perl -w
package version::vxs;

use 5.005_03;
use strict;

require Exporter;
require DynaLoader;
use vars qw(@ISA $VERSION $CLASS @EXPORT);

@ISA = qw(Exporter DynaLoader);

@EXPORT = qw(qv);

$VERSION = "0.48"; 

$CLASS = 'version::vxs';

local $^W; # shut up the 'redefined' warning for UNIVERSAL::VERSION
bootstrap version::vxs if $] < 5.009;

# Preloaded methods go here.

1;
