#!perl -w
package version;

use 5.005_04;
use strict;

use vars qw(@ISA $VERSION $CLASS *qv);

$VERSION = 0.65;

$CLASS = 'version';

eval "use version::vxs $VERSION";
if ( $@ ) { # don't have the XS version installed
    eval "use version::vpp $VERSION"; # don't tempt fate
    die "$@" if ( $@ );
    push @ISA, "version::vpp";
    *version::qv = \&version::vpp::qv;
}
else { # use XS module
    push @ISA, "version::vxs";
    *version::qv = \&version::vxs::qv;
}

# Preloaded methods go here.
sub import {
    my ($class) = @_;
    my $callpkg = caller();
    no strict 'refs';
    
    *{$callpkg."::qv"} = 
	    sub {return bless version::qv(shift), $class }
	unless defined(&{"$callpkg\::qv"});

}

1;
