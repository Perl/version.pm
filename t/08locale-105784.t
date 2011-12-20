#! perl -w
# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

#########################

use Test::More qw/no_plan/;
use strict;
use locale;
use POSIX qw/locale_h/;

SKIP: {
	# test locale handling
	(my $helper = $0) =~ s|[^/]+.t$|comma_locale.pl|;
	my $loc = qx|$helper|;
	skip 'Cannot test locale handling without a comma locale', 2
	    unless $loc;

	diag ("Testing locale handling with $loc") unless $ENV{PERL_CORE};

	my $i = 0.123;
	POSIX::setlocale(POSIX::LC_NUMERIC(),$loc);
	is sprintf("%.2f", $i), '0,12', 'Before loading version';
	require version;
	is sprintf("%.2f", $i), '0,12', 'After loading version';
}

