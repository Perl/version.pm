#! /usr/local/perl -w
# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

#########################

use Test::More qw/no_plan/;
use Data::Dumper;
my $Verbose;

BEGIN {
    require "t/coretests.pm";
    use_ok('version', 0.78);
}

while (my $test = <DATA>) {
    chomp($test);
    print "'$test'\n";
    eval "
	my \$v = version->new(\"$test\");
	print Dumper(\$v);
    ";
    print $@ if $@;
    eval "
	my \$v = version->new($test);
	print Dumper(\$v);
    ";
}

__DATA__
v1
v1.2
v1.2.3_4
1.2.3
1.2.3.4
1.2.3_4
v1_000
v01_000
v01.2.3
v01
