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

sub import {
    my ($pkg, $num) = @_;
    my $caller = caller;
    no strict 'refs';
    my $bootstrap;
    tie $bootstrap, 'version::_bootstrap', $num, $pkg;
    *{"$caller\::VERSION"} = \$bootstrap;
    $pkg->export_to_level(1, @_);
}

package version::_bootstrap;

require Tie::Scalar;
use vars qw(@ISA);

@ISA = qw(Tie::StdScalar);

sub TIESCALAR {
    my ($class, $value, $package) = @_;
    my $self = bless {}, $class;
    $self->{value} = $value;
    $self->{class} = $package;
    return $self;
}

sub STORE {
    $DB::single = 1;
    my $class = $_[0]->{class};
    untie $_[0];
    undef $_[0];
    $_[0] = $class->new($_[1]);
    return ;
}

sub DESTROY {
    return;
}

1;
