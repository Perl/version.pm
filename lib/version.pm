#!perl -w
package version;

use 5.005_04;
use strict;

use vars qw(@ISA $VERSION $CLASS *qv);

$VERSION = "0.59_02";
$VERSION = eval($VERSION);

$CLASS = 'version';

sub import {
    my ($class, @args) = @_;
    my $callpkg = caller();
    no strict 'refs';
    
    eval "use version::vxs $VERSION";
    if ( $@ ) { # don't have the XS version installed
	eval "use version::vpp $VERSION"; # don't tempt fate
	die "$@" if ( $@ );
	push @ISA, "version::vpp";
	*qv = \&version::vpp::qv;
    }
    else { # use XS module
	push @ISA, "version::vxs";
	*qv = \&version::vxs::qv;
    }
    *{$callpkg."::qv"} = 
	    sub {return bless version::qv(shift), $class };
}

# Preloaded methods go here.

1;
