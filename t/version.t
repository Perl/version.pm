# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'
# $Revision: 1.1 $

#########################

use Test::More tests => 50;
use version;
ok(1); # If we made it this far, we're ok.

my ($version, $new_version);
#########################

# Insert your test code below, the Test module is use()ed here so read
# its man page ( perldoc Test ) for help writing this test script.

# Test stringify operator
print "# tests with stringify\n";
$version = new version "5.005";
is ( "$version" , "5.5" , '5.005 eq 5.5' );
$version = new version "5.005_03";
is ( "$version" , "5.5.30" , 'perl version 5.005_03 eq 5.5.30' );
$version = new version "5.006.001";
is ( "$version" , "5.6.1" , '5.006.001 eq 5.6.1' );
$version = new version "1.2.3_4";
is ( "$version" , "1.2.3_4" , 'beta version 1.2.3_4 eq 1.2.3_4' );

# test illegal format
eval {my $version = new version "1_23.1_24.1_25";};
like($@, qr/multiple underscores/,
	"Invalid version format (multiple underscores)");

# Test boolean operator
ok ($version, 'boolean');

# Test ref operator
ok (ref($version) eq 'version','ref operator');
# Test numify operator
ok ( $version->numify == 1.002003004, '$version->numify == 1.002003004' );

# Test comparison operators with self
print "# tests with self\n";
ok ( $version eq $version, '$version eq $version' );
is ( $version cmp $version, 0, '$version cmp $version == 0' );
ok ( $version == $version, '$version == $version' );

# test first with non-object
$version = new version "5.006.001";
$new_version = "5.8.0";
print "# tests with non-objects\n";
ok ( $version ne $new_version, '$version ne $new_version' );
ok ( $version lt $new_version, '$version lt $new_version' );
ok ( $new_version gt $version, '$new_version gt $version' );
ok ( ref(\$new_version) eq 'SCALAR', 'no auto-upgrade');
$new_version = "$version";
ok ( $version eq $new_version, '$version eq $new_version' );
ok ( $new_version eq $version, '$new_version eq $version' );

# now test with existing object
$new_version = new version "5.8.0";
print "# tests with objects\n";
ok ( $version ne $new_version, '$version ne $new_version' );
ok ( $version lt $new_version, '$version lt $new_version' );
ok ( $new_version gt $version, '$new_version gt $version' );
$new_version = new version "$version";
ok ( $version eq $new_version, '$version eq $new_version' );

# Test Numeric Comparison operators
# test first with non-object
$new_version = "5.8.0";
print "# numeric tests with non-objects\n";
ok ( $version == $version, '$version == $version' );
ok ( $version < $new_version, '$version < $new_version' );
ok ( $new_version > $version, '$new_version > $version' );
ok ( $version != $new_version, '$version != $new_version' );

# now test with existing object
$new_version = new version $new_version;
print "# numeric tests with objects\n";
ok ( $version < $new_version, '$version < $new_version' );
ok ( $new_version > $version, '$new_version > $version' );
ok ( $version != $new_version, '$version != $new_version' );

# now test with actual numbers
print "# numeric tests with numbers\n";
ok ( $version->numify() == 5.006001, '$version->numify() == 5.006001' );
ok ( $version->numify() <= 5.006001, '$version->numify() <= 5.006001' );
ok ( $version->numify() < 5.008, '$version->numify() < 5.008' );
#ok ( $version->numify() > v5.005_02, '$version->numify() > 5.005_02' );

# now test with Beta version form with string
$version = new version "1.2.3";
$new_version = "1.2.3_4";
print "# tests with beta-style non-objects\n";
ok ( $version < $new_version, '$version < $new_version' );
ok ( $new_version > $version, '$new_version > $version' );
ok ( $version != $new_version, '$version != $new_version' );

$version = new version "1.2.4";
print "# numeric tests with beta-style non-objects\n";
ok ( $version > $new_version, '$version > $new_version' );
ok ( $new_version < $version, '$new_version < $version' );
ok ( $version != $new_version, '$version != $new_version' );

# now test with Beta version form with object
$version = new version "1.2.3";
$new_version = new version "1.2.3_4";
print "# tests with beta-style objects\n";
ok ( $version < $new_version, '$version < $new_version' );
ok ( $new_version > $version, '$new_version > $version' );
ok ( $version != $new_version, '$version != $new_version' );

$version = new version "1.2.4";
print "# numeric tests with beta-style objects\n";
ok ( $version > $new_version, '$version > $new_version' );
ok ( $new_version < $version, '$new_version < $version' );
ok ( $version != $new_version, '$version != $new_version' );

# that which is not expressly permitted is forbidden
print "# forbidden operations\n";
ok ( !eval { $version++ }, "noop ++" );
ok ( !eval { $version-- }, "noop --" );
ok ( !eval { $version/1 }, "noop /" );
ok ( !eval { $version*3 }, "noop *" );
ok ( !eval { abs($version) }, "noop abs" );
