#!perl -w
package version::vxs;

use 5.005_03;
use strict;

use vars qw(@ISA $VERSION $CLASS );
$VERSION = 0.9905;
$CLASS = 'version::vxs';

require version::regex;
*version::vxs::is_strict = \&version::regex::is_strict;
*version::vxs::is_lax = \&version::regex::is_lax;

eval {
    require XSLoader;
    local $^W; # shut up the 'redefined' warning for UNIVERSAL::VERSION
    XSLoader::load('version::vxs', $VERSION);
    1;
} or do {
    require DynaLoader;
    push @ISA, 'DynaLoader'; 
    local $^W; # shut up the 'redefined' warning for UNIVERSAL::VERSION
    bootstrap version::vxs $VERSION;
};

# Preloaded methods go here.

1;
