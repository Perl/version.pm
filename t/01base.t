#! /usr/local/perl -w
# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

#########################

use Test::More qw/no_plan/;

BEGIN {
    use_ok("version", 0.58); # If we made it this far, we are ok.
}

my $Verbose;
require "t/coretests.pm";

diag "Tests with base class" if $Verbose;

BaseTests("version");

# dummy up a redundant call to satify David Wheeler
local $SIG{__WARN__} = sub { die $_[0] };
eval 'use version;';
unlike ($@, qr/^Subroutine main::qv redefined/,
    "Only export qv once per package (to prevent redefined warnings)."); 
