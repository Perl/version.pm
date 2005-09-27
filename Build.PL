#!/usr/bin/perl

use Module::Build;

my $perl_only;

my $t = Module::Build->new(
    module_name     => 'version',
    get_options     => {
       'perl_only' => { store => \$perl_only },
    },
);

my %build_arguments = (
    dist_name       => 'version',
    dist_version_from => 'lib/version.pm',
    license         => 'perl',
    requires        => {
	perl => '> 5.005, !=5.9.1, !=5.9.2',
    },
    PL_files        => {
	't/01base.t.PL' => 't/01base.t'
    },
);

if ( $perl_only or not $t->have_c_compiler() ) {
    $build_arguments{module_name} = 'version::vpp';
    $build_arguments{pm_files} = {
	'./lib/version.pm' => './lib/version.pm',
	'./vperl/vpp.pm' => 'lib/version/vpp.pm',
    };
}
else {
    $build_arguments{c_source} = './vutil';
    $build_arguments{module_name} = 'version::vxs';
    $build_arguments{pm_files} = {
	'./lib/version.pm' => './lib/version.pm',
	'./vutil/vxs.pm' => 'lib/version/vxs.pm'
    };
    $build_arguments{xs_files} = {
	'./vutil/vxs.xs' => 'lib/version/vxs.xs'
    };
}

my $class = Module::Build->subclass
(
    class => 'version::Builder',
    code => q{
    sub ACTION_dist{
        my $self = shift;
    	$self->do_system('svk log -x | gnuify-changelog.pl > Changes');
	$self->SUPER::ACTION_dist();
	}
    },
);

my $m = $class->new(%build_arguments);

$m->create_build_script;
