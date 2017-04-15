#!perl -T
use Test::More qw/no_plan/;

use Test::Taint;
use version;

taint_checking_ok();
my $v = 'v1.2.3';
taint($v);
tainted_ok($v);
my $v2 = version->parse($v);
isnt("$v2", '', 'Correctly parsed the tainted string');
tainted_ok($v2);

my $vs = "$v2";
is $v2, 'v1.2.3';
