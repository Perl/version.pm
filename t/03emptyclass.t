use Test::More tests => 78;

$CLASS = "version::Empty";

use_ok($CLASS); # If we made it this far, we are ok.

my $testobj = new $CLASS 1.002_003;
ok( ref($testobj) eq "version::Empty", "Created derived object" );
ok( $testobj->numify == 1.002003, "Numified correctly" );
ok( $testobj->stringify eq "1.2.3", "Stringified correctly" );

my $verobj = new version "1.2.4";

ok( $verobj > $testobj, "Comparison vs parent class" );

do "t/basetests.inc";
