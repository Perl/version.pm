package version;

use 5.006;
use strict;
use warnings;

require Exporter;
require DynaLoader;

our @ISA = qw(Exporter DynaLoader);

# This allows declaration	use Universal::Version ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(

) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(

);
our $VERSION = qw$Revision: 1.1 $[1]/10;

use overload 	'+'	=>	\&noop,
		'-'	=>	\&noop,
		'*'	=>	\&noop,
		'/'	=>	\&noop,
		'<=>'	=>	\&vcmp,
		'cmp'	=>	\&vcmp,
                '""'	=>	\&stringify,
		'0+'	=>	\&numify,
		'abs'	=>	\&noop,
		'bool'	=>	\&boolean,
;

our $CLASS = 'version';

bootstrap version;

# Preloaded methods go here.

1;
__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

Universal::Version - Perl extension for Version Objects

=head1 SYNOPSIS

  use Universal::Version;
  $version = new Universal::Version "12.2.1"; # must be quoted for now

=head1 DESCRIPTION

Proof of concept for Version objects to test the behavior of the feature.

NOTE: No real verification of version format is done right now.  Don't feed
this arbitrary strings; you will get your hand bitten off. ;~)

=head2 EXPORT

None by default.


=head1 AUTHOR

John Peacock E<lt>jpeacock@rowman.comE<gt>

=head1 SEE ALSO

L<perl>.

=cut
