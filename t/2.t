# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl 1.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 11;
BEGIN { use_ok('version::AlphaBeta') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

my $v = new version::AlphaBeta "1.2rc1";
ok ("v1.2rc1" eq "$v", "Release candidate: [$v]");

$v = new version::AlphaBeta "1.2b";
ok ("v1.2b" eq "$v", "Beta: [$v]");
ok ("v1.2b" eq  $v, "v1.2b eq Beta");
ok ("v1.2b" == $v, "v1.2b == Beta");

$v = new version::AlphaBeta "v1.2";
ok ("v1.2" eq "$v", "Release: [$v]");
ok ("1.2a" < $v , "Alpha < Release");

my $v2 = new version::AlphaBeta "1.2rc1";
ok ( $v > $v2 , "Release > Release Candidate ");
ok ( $v2 > "1.2a", "Release Candidate > Alpha");

eval { my $v3 = new version::AlphaBeta "nothing" };
like($@, qr/Illegal version string format/, substr($@,0,index($@," at ")) );
eval { my $v3 = new version::AlphaBeta "1.2.3" };
like($@, qr/Illegal version string format/, substr($@,0,index($@," at ")) );
