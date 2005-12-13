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
    *{"$caller\::VERSION"} = version::_bootstrap->new($pkg,$num);
    $pkg->export_to_level(1, @_);
}

package version::_bootstrap;

require Tie::Scalar;
use vars qw(@ISA);

@ISA = qw(Tie::StdScalar);

sub new {
    my ($tramp_class, $real_class, @args) = @_;
    my $self;
    tie $self, $tramp_class, \$self, @args;
    bless \$self, $real_class;
}

sub TIESCALAR {
    $DB::single = 1;
    my ($class, $orig, @args) = @_;
    bless { orig => $orig, args => \@args }, $class;
}

sub _snap {
    $DB::single = 1;
    untie ${$_[0]{orig}};
    my $class = ref($_[0]);
    $class->new($_[0]{orig}, @{$_[0]{args}});
}

sub STORE {
    $DB::single = 1;
    &_snap->{$_[1]} = $_[2];
}

sub DESTROY {
    return;
}

1;
