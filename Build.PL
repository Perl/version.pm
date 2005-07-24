#!/usr/bin/perl

use Module::Build;
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

my $m = $class->new(
    module_name     => 'version',
    license         => 'perl',
    c_source        => './vutil',
);
$m->create_build_script;
