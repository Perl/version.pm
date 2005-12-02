#!perl -w
package version;

use 5.005_03;
use strict;

require Exporter;
use vars qw(@ISA $VERSION $CLASS @EXPORT);

@ISA = qw(Exporter);

@EXPORT = qw(qv);

$VERSION = "0.50"; 

$CLASS = 'version';

eval { require version::vxs; };

if ( $@ ) # don't have the XS version installed
{
#    eval { require version::vpp }; # don't tempt fate
    die "$@" if ( $@ );
#    push @ISA, "version::PP";
#    *qv = \&version::vpp::qv;
}
else # use XS module
{
    push @ISA, "version::vxs";
    *qv = \&version::vxs::qv;
}

# Preloaded methods go here.

1;
