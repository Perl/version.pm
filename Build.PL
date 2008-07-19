#!/usr/bin/perl

use Module::Build;
my $perl_only;

my $class = Module::Build->subclass
(
#    class => 'version::Builder',
    code => q{
	sub ACTION_dist{
	    my $self = shift;
	    $self->do_system('svk log -x | gnuify-changelog.pl > Changes');
	    $self->SUPER::ACTION_dist();
	};
	sub have_c_compiler{
	my $self = shift;
	my $have = eval {$self->SUPER::have_c_compiler};
	$have = 0 if $@;
	return $have;
	};
    },
);

my $t = $class->new(
    module_name     => 'version',
    get_options     => {
       'perl_only' => { store => \$perl_only },
    },
);

my %build_arguments = (
    module_name     => 'version',
    license         => 'perl',
    requires        => {
	perl => '> 5.005',
    },
    dynamic_config  => 1,
    installdirs     =>
	($] > 5.009001 && $] <= 5.010000) ? 'core' : 'site',
);

mkdir($t->config_dir(),0777);

if ( $] < 5.005_04 ) {
    # Cannot support 5.005_03 with the XS code
    $perl_only = 1;
}
if ( $perl_only or not $t->have_c_compiler() ) {
    $build_arguments{pm_files} = {
	'./lib/version.pm' => './lib/version.pm',
	'./vperl/vpp.pm' => './lib/version/vpp.pm',
    };
}
else {
    $build_arguments{c_source} = './vutil';
    $build_arguments{pm_files} = {
	'./lib/version.pm' => './lib/version.pm',
	'./vutil/lib/version/vxs.pm' => './lib/version/vxs.pm'
    };
    $build_arguments{xs_files} = {
	'./vutil/vxs.xs' => './lib/version/vxs.xs'
    };
    $build_arguments{add_to_cleanup} = 
	['lib/version/vxs.*'];
}

my $m = $class->new(%build_arguments);

$m->create_build_script;
