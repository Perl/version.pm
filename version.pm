package version;

use 5.005_03;
use strict;
#use warnings;

require Exporter;
require DynaLoader;
use vars qw(@ISA %EXPORT_TAGS @EXPORT_OK @EXPORT $VERSION $CLASS);

@ISA = qw(Exporter Dynaloader);

# This allows declaration	use Universal::Version ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
%EXPORT_TAGS = ( 'all' => [ qw(

) ] );

@EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

@EXPORT = qw(
);

$VERSION = (qw$Revision: 1.3 $)[1]/10;

$CLASS = 'version';

bootstrap version;

# Preloaded methods go here.

1;

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
