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

sub import {
    no strict 'refs';
    my ($class) = shift;

    # Set up any derived class
    unless ($class eq $CLASS) {
	local $^W;
	*{$class.'::declare'} =  \&{$CLASS.'::declare'};
	*{$class.'::qv'} = \&{$CLASS.'::qv'};
    }

    my %args;
    if (@_) { # any remaining terms are arguments
	map { $args{$_} = 1 } @_
    }
    else { # no parameters at all on use line
	%args =
	(
	    qv => 1,
	    'UNIVERSAL::VERSION' => 1,
	);
    }

    my $callpkg = caller();

    if (exists($args{declare})) {
	*{$callpkg.'::declare'} =
	    sub {return $class->declare(shift) }
	  unless defined(&{$callpkg.'::declare'});
    }

    if (exists($args{qv})) {
	*{$callpkg.'::qv'} =
	    sub {return $class->qv(shift) }
	  unless defined(&{$callpkg.'::qv'});
    }

    if (exists($args{'UNIVERSAL::VERSION'})) {
	local $^W;
	*UNIVERSAL::VERSION
		= \&{$CLASS.'::_VERSION'};
    }

    if (exists($args{'VERSION'})) {
	*{$callpkg.'::VERSION'} = \&{$CLASS.'::_VERSION'};
    }

    if (exists($args{'is_strict'})) {
	*{$callpkg.'::is_strict'} = \&{$CLASS.'::is_strict'}
	  unless defined(&{$callpkg.'::is_strict'});
    }

    if (exists($args{'is_lax'})) {
	*{$callpkg.'::is_lax'} = \&{$CLASS.'::is_lax'}
	  unless defined(&{$callpkg.'::is_lax'});
    }
}

1;
