# Not a standalone test file; must be called with the global
# variable $CLASS set and the correct number of tests issued

use_ok($CLASS); # If we made it this far, we are ok.

# Insert your test code below, the Test module is use()ed here so read
# its man page ( perldoc Test ) for help writing this test script.

# Test bare number processing
diag "tests with bare numbers" unless $ENV{PERL_CORE};
$version = new $CLASS 5.005_03;
is ( "$version" , "5.5.30" , '5.005_03 eq 5.5.30' );
$version = new $CLASS 1.23;
is ( "$version" , "1.230" , '1.23 eq "1.230"' );

# Test quoted number processing
diag "tests with quoted numbers" unless $ENV{PERL_CORE};
$version = new $CLASS "5.005_03";
is ( "$version" , "5.5_3" , '"5.005_03" eq "5.5_3"' );
$version = new $CLASS "v1.23";
is ( "$version" , "1.23" , '"v1.23" eq "1.23"' );

# Test stringify operator
diag "tests with stringify" unless $ENV{PERL_CORE};
$version = new $CLASS "5.005";
is ( "$version" , "5.5" , '5.005 eq 5.5' );
$version = new $CLASS "5.006.001";
is ( "$version" , "5.6.1" , '5.006.001 eq 5.6.1' );
$version = new $CLASS "1.2.3_4";
is ( "$version" , "1.2.3_4" , 'alpha version 1.2.3_4 eq 1.2.3_4' );

# test illegal formats
diag "test illegal formats" unless $ENV{PERL_CORE};
eval {my $version = new $CLASS "1.2_3_4";};
like($@, qr/multiple underscores/,
    "Invalid version format (multiple underscores)");

eval {my $version = new $CLASS "1.2_3.4";};
like($@, qr/underscores before decimal/,
    "Invalid version format (underscores before decimal)");

$version = new $CLASS "99 and 44/100 pure";
ok ("$version" eq "99.0", '$version eq "99.0"');
ok ($version->numify == 99.0, '$version->numify == 99.0');

$version = new $CLASS "something";
ok (defined $version, 'defined $version');

# reset the test object to something reasonable
$version = new $CLASS "1.2.3";

# Test boolean operator
ok ($version, 'boolean');

# Test class membership
isa_ok ( $version, "version" );

# Test comparison operators with self
diag "tests with self" unless $ENV{PERL_CORE};
ok ( $version eq $version, '$version eq $version' );
is ( $version cmp $version, 0, '$version cmp $version == 0' );
ok ( $version == $version, '$version == $version' );

# test first with non-object
$version = new $CLASS "5.006.001";
$new_version = "5.8.0";
diag "tests with non-objects" unless $ENV{PERL_CORE};
ok ( $version ne $new_version, '$version ne $new_version' );
ok ( $version lt $new_version, '$version lt $new_version' );
ok ( $new_version gt $version, '$new_version gt $version' );
ok ( ref(\$new_version) eq 'SCALAR', 'no auto-upgrade');
$new_version = "$version";
ok ( $version eq $new_version, '$version eq $new_version' );
ok ( $new_version eq $version, '$new_version eq $version' );

# now test with existing object
$new_version = new $CLASS "5.8.0";
diag "tests with objects" unless $ENV{PERL_CORE};
ok ( $version ne $new_version, '$version ne $new_version' );
ok ( $version lt $new_version, '$version lt $new_version' );
ok ( $new_version gt $version, '$new_version gt $version' );
$new_version = new $CLASS "$version";
ok ( $version eq $new_version, '$version eq $new_version' );

# Test Numeric Comparison operators
# test first with non-object
$new_version = "5.8.0";
diag "numeric tests with non-objects" unless $ENV{PERL_CORE};
ok ( $version == $version, '$version == $version' );
ok ( $version < $new_version, '$version < $new_version' );
ok ( $new_version > $version, '$new_version > $version' );
ok ( $version != $new_version, '$version != $new_version' );

# now test with existing object
$new_version = new $CLASS $new_version;
diag "numeric tests with objects" unless $ENV{PERL_CORE};
ok ( $version < $new_version, '$version < $new_version' );
ok ( $new_version > $version, '$new_version > $version' );
ok ( $version != $new_version, '$version != $new_version' );

# now test with actual numbers
diag "numeric tests with numbers" unless $ENV{PERL_CORE};
ok ( $version->numify() == 5.006001, '$version->numify() == 5.006001' );
ok ( $version->numify() <= 5.006001, '$version->numify() <= 5.006001' );
ok ( $version->numify() < 5.008, '$version->numify() < 5.008' );
#ok ( $version->numify() > v5.005_02, '$version->numify() > 5.005_02' );

# test with long decimals
diag "Tests with extended decimal versions" unless $ENV{PERL_CORE};
$version = new $CLASS 1.002003;
ok ( $version eq "1.2.3", '$version eq "1.2.3"');
ok ( $version->numify == 1.002003, '$version->numify == 1.002003');
$version = new $CLASS "2002.09.30.1";
ok ( $version eq "2002.9.30.1",'$version eq 2002.9.30.1');
ok ( $version->numify == 2002.009030001,
    '$version->numify == 2002.009030001');

# now test with alpha version form with string
$version = new $CLASS "1.2.3";
$new_version = "1.2.3_4";
diag "tests with alpha-style non-objects" unless $ENV{PERL_CORE};
ok ( $version lt $new_version, '$version lt $new_version' );
ok ( $new_version gt $version, '$new_version gt $version' );
ok ( $version ne $new_version, '$version ne $new_version' );

$version = new $CLASS "1.2.4";
diag "numeric tests with alpha-style non-objects" unless $ENV{PERL_CORE};
ok ( $version > $new_version, '$version > $new_version' );
ok ( $new_version < $version, '$new_version < $version' );
ok ( $version != $new_version, '$version != $new_version' );

# now test with alpha version form with object
$version = new $CLASS "1.2.3";
$new_version = new $CLASS "1.2.3_4";
diag "tests with alpha-style objects" unless $ENV{PERL_CORE};
ok ( $version < $new_version, '$version < $new_version' );
ok ( $new_version > $version, '$new_version > $version' );
ok ( $version != $new_version, '$version != $new_version' );
ok ( !$version->is_alpha, '!$version->is_alpha');
ok ( $new_version->is_alpha, '$new_version->is_alpha');

$version = new $CLASS "1.2.4";
diag "tests with alpha-style objects" unless $ENV{PERL_CORE};
ok ( $version > $new_version, '$version > $new_version' );
ok ( $new_version < $version, '$new_version < $version' );
ok ( $version != $new_version, '$version != $new_version' );

$version = new $CLASS "1.2.4";
$new_version = new $CLASS "1.2_4";
diag "tests with alpha-style objects with same subversion" unless $ENV{PERL_CORE};
ok ( $version > $new_version, '$version > $new_version' );
ok ( $new_version < $version, '$new_version < $version' );
ok ( $version != $new_version, '$version != $new_version' );

diag "test implicit [in]equality" unless $ENV{PERL_CORE};
$version = new $CLASS "v1.2";
$new_version = new $CLASS "1.2.0";
ok ( $version == $new_version, '$version == $new_version' );
$new_version = new $CLASS "1.2_0";
ok ( $version == $new_version, '$version == $new_version' );
$new_version = new $CLASS "1.2.1";
ok ( $version < $new_version, '$version < $new_version' );
$new_version = new $CLASS "1.2_1";
ok ( $version < $new_version, '$version < $new_version' );
$new_version = new $CLASS "1.1.999";
ok ( $version > $new_version, '$version > $new_version' );

# that which is not expressly permitted is forbidden
diag "forbidden operations" unless $ENV{PERL_CORE};
ok ( !eval { $version++ }, "noop ++" );
ok ( !eval { $version-- }, "noop --" );
ok ( !eval { $version/1 }, "noop /" );
ok ( !eval { $version*3 }, "noop *" );
ok ( !eval { abs($version) }, "noop abs" );

# test reformed UNIVERSAL::VERSION
diag "Replacement UNIVERSAL::VERSION tests" unless $ENV{PERL_CORE};

# we know this file is here since we require it ourselves
$version = new $CLASS $Test::More::VERSION;
eval "use Test::More $version";
unlike($@, qr/Test::More version $version required/,
	'Replacement eval works with exact version');

$version = new $CLASS $Test::More::VERSION+0.01; # this should fail even with old UNIVERSAL::VERSION
eval "use Test::More $version";
like($@, qr/Test::More version $version required/,
	'Replacement eval works with incremented version');

chop($version); # shorten by 1 digit, should still succeed
eval "use Test::More $version";
unlike($@, qr/Test::More version $version required/,
	'Replacement eval works with single digit');

$version += 0.1; # this would fail with old UNIVERSAL::VERSION
eval "use Test::More $version";
unlike($@, qr/Test::More version $version required/,
	'Replacement eval works with incremented digit');

