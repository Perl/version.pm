#! /usr/local/perl -w
# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

#########################

use File::Basename;
use File::Temp qw/tempfile/;
use POSIX qw/locale_h/;
use Test::More tests => 7;

BEGIN {
    use_ok('version', 0.96);
}

SKIP: {
	# test locale handling
	my $warning;
	local $SIG{__WARN__} = sub { $warning = $_[0] };

	(my $helper = $0) =~ s|[^/]+.t$|comma_locale.pl|;
	my $loc = qx|$helper|;
	skip 'Cannot test locale handling without a comma locale', 4
	    unless $loc;

	diag ("Testing locale handling with $loc") unless $ENV{PERL_CORE};

	my $orig_loc = setlocale(LC_NUMERIC);
	my $ver = 1.23;
	is ($ver, '1.23', 'Not using locale yet');
	setlocale(LC_NUMERIC, $loc);
	is ($ver, '1,23', "Using locale: $loc");
	$v = version->new($ver);
	unlike($warning, qr/Version string '1,23' contains invalid data/,
	    "Process locale-dependent floating point");
	is ($v, "1.23", "Locale doesn't apply to version objects");
	ok ($v == $ver, "Comparison to locale floating point");

	setlocale( LC_ALL, $orig_loc); # reset this before possible skip
	skip 'Cannot test RT#46921 with Perl < 5.008', 1
	    if ($] < 5.008);
	skip 'Cannot test RT#46921 with pure Perl module', 1
	    if exists $INC{'version/vpp.pm'};
	my ($fh, $filename) = tempfile('tXXXXXXX', SUFFIX => '.pm', UNLINK => 1);
	(my $package = basename($filename)) =~ s/\.pm$//;
	print $fh <<"EOF";
package $package;
use POSIX qw(locale_h);
\$^W = 1;
use version;
setlocale (LC_ALL, '$loc');
use version ;
eval "use Socket 1.7";
setlocale( LC_ALL, '$orig_loc');
1;
EOF
	close $fh;

	eval "use lib '.'; use $package;";
	unlike($warning, qr"Version string '1,7' contains invalid data",
	    'Handle locale action-at-a-distance');
    }
