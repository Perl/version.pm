#! /usr/local/perl -w
# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

#########################

use Test::More qw/no_plan/;

BEGIN {
    use_ok("version", 0.76_02); # If we made it this far, we are ok.
}

my $Verbose;
require "t/coretests.pm";
use lib "t/lib";

diag "Tests with empty derived class"  if $Verbose;

sub main_reset {
    delete $main::INC{'version::Empty'};
    undef &qv; undef *::qv; # avoid 'used once' warning
    undef &declare; undef *::declare; # avoid 'used once' warning
}

package version::Bad;
use base 'version';
sub new { my($self,$n)=@_;  bless \$n, $self }

package main;
use_ok("version::Empty", 0.001);
my $testobj = version::Empty->new(1.002_003);
isa_ok( $testobj, "version::Empty" );
ok( $testobj->numify == 1.002003, "Numified correctly" );
ok( $testobj->stringify eq "1.002003", "Stringified correctly" );
ok( $testobj->normal eq "v1.2.3", "Normalified correctly" );

my $verobj = version::->new("1.2.4");
ok( $verobj > $testobj, "Comparison vs parent class" );

BaseTests("version::Empty", "new", "qv");
main_reset;
use_ok("version::Empty", 0.001, "declare");
BaseTests("version::Empty", "new", "declare");
main_reset;
use_ok("version::Empty", 0.001);
BaseTests("version::Empty", "parse", "qv");
main_reset;
use_ok("version::Empty", 0.001, "declare");
BaseTests("version::Empty", "parse", "declare");
main_reset;
use_ok("version::Empty", 0.001);

diag "tests with bad subclass"  if $Verbose;
$testobj = version::Bad->new(1.002_003);
isa_ok( $testobj, "version::Bad" );
eval { my $string = $testobj->numify };
like($@, qr/Invalid version object/,
    "Bad subclass numify");
eval { my $string = $testobj->normal };
like($@, qr/Invalid version object/,
    "Bad subclass normal");
eval { my $string = $testobj->stringify };
like($@, qr/Invalid version object/,
    "Bad subclass stringify");
eval { my $test = ($testobj > 1.0) };
like($@, qr/Invalid version object/,
    "Bad subclass vcmp");
