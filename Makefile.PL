# This Makefile.PL stolen from Params::Validate
#
# The perl/C checking voodoo is stolen from Graham Barr's
# Scalar-List-Utils distribution.

use strict;

use ExtUtils::MakeMaker;
use Config qw(%Config);
use File::Spec;

my $no_xs;
my $force_xs;
for (@ARGV)
{
    /^--perl_only/ and $no_xs = 1;
    /^--xs/ and $no_xs = 0;
}

if ($no_xs)
{
    write_makefile();
    exit;
}

unless (defined $no_xs)
{
    check_for_compiler()
        or no_cc();

    map { unlink $_ if -f $_ } ('test.c',"test$Config{obj_ext}");

}

write_makefile();

sub write_makefile
{
    my %prereq = ( 'Test::More' => 0 );

    WriteMakefile( VERSION_FROM    => "lib/version.pm",
                   NAME            => "version",
                   PREREQ_PM       => \%prereq,
                   CONFIGURE       => \&init,
                   ( $] >= 5.005 ?
                     ( ABSTRACT    => 'Structured version objects',
                       AUTHOR      => 'John Peacock <jpeacock@cpan.org>') :
                     ()
                   ), 
		   PM              => 
		       {'lib/version.pm' => '$(INST_LIBDIR)/version.pm'},
		   PL_FILES        => {},

		   clean           => { FILES => 'vutil/Makefile.PL' },
                 );
}

sub init
{
    my $hash = $_[1];

    if ($no_xs) {
	$hash->{'PM'}->{'vperl/vpp.pm'} = '$(INST_LIBDIR)/version/vpp.pm';
    }
    else {
	require File::Copy;
	File::Copy::copy('vutil/Makefile.PLz','vutil/Makefile.PL');
        @{ $hash }{ 'DIR' } = ['vutil'];
    }

    $hash;
}

sub no_cc
{
    $no_xs = 1;
    print <<'EOF';

 I cannot determine if you have a C compiler
 so I will install a perl-only implementation

 You can force installation of the XS version with

    perl Makefile.PL --xs

EOF

    write_makefile();
    exit;
}

sub check_for_compiler
{
    print "Testing if you have a C compiler\n";

    eval { require ExtUtils::CBuilder };
    if ($@)
    {
        return _check_for_compiler_manually();
    }
    else
    {
        return _check_for_compiler_with_cbuilder();
    }
}

sub _check_for_compiler_with_cbuilder
{
    my $cb = ExtUtils::CBuilder->new( quiet => 1 );

    return $cb->have_compiler;
}

sub _check_for_compiler_manually
{
    unless ( open F, ">test.c" )
    {
        warn "Cannot write test.c, skipping test compilation and installing pure Perl version.\n";
        return 0;
    }

    print F <<'EOF';
int main() { return 0; }
EOF

    close F or return 0;

    system( "$Config{cc} -o test$Config{obj_ext} test.c" ) and return 0;

    return 1;
}
