#! /usr/local/perl -w
# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

#########################

use Test::More qw/no_plan/;
no warnings 'once';
require "t/coretests.pm";

BEGIN {
    use_ok("version", 0.57); # If we made it this far, we are ok.
}

diag "Tests with base class" if $Verbose;

BaseTests("version");
