#!/usr/local/bin/perl -w
package version;

use 5.005_03;
use strict;

require Exporter;
require DynaLoader;
use vars qw(@ISA %EXPORT_TAGS @EXPORT_OK @EXPORT $VERSION $CLASS);

@ISA = qw(Exporter DynaLoader);

# This allows declaration	use version ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
%EXPORT_TAGS = ( 'all' => [ qw(

) ] );

@EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

@EXPORT = qw(
);

$VERSION = (qw$Revision: 1.7 $)[1]/10;

$CLASS = 'version';

bootstrap version if $] < 5.009;

# Preloaded methods go here.

1;
__END__

=head1 NAME

version - Perl extension for Version Objects

=head1 SYNOPSIS

  use version;
  $version = new version "12.2.1"; # must be quoted!
  print $version; 		# 12.2.1
  print $version->numify; 	# 12.002001
  if ( $version > 12.2 )	# true

  $vstring = new version qw(v1.2); # must be quoted!
  print $vstring;		# 1.2

  $betaver = new version "1.2_3"; # must be quoted!
  print $betaver;		# 1.2_3

  $perlver = new version "5.005_03"; # must be quoted!
  print $perlver;		# 5.5.30

=head1 DESCRIPTION

Overloaded version objects for all versions of Perl.  This module
implments all of the features of version objects which will be part
of Perl v5.10 except automatic v-string handling.  See L<"Quoting">.

=head2 Quoting

Because of the nature of the Perl parsing and tokenizing routines, 
you should always quote the parameter to the new() operator/method.  The
exact notation is vitally important to correctly determine the version
that is requested.  You don't B<have> to quote the version parameter,
but you should be aware of what Perl is likely to do in those cases.

If you use a mathematic formula that resolves to a floating point number,
you are dependent on Perl's conversion routines to yield the version you
expect.  You are pretty safe by dividing by a power of 10, for example,
but other operations are not likely to be what you intend.  For example:

  $VERSION = new version (qw$Revision: 1.4)[1]/10;
  print $VERSION;          # yields 0.14
  $V2 = new version 100/9; # Integer overflow in decimal number
  print $V2;               # yields 11_1285418553

You can use a bare number, if you only have a major and minor version,
since this should never in practice yield a floating point notation
error.  For example:

  $VERSION = new version  10.2;  # almost certainly ok
  $VERSION = new version "10.2"; # guaranteed ok

Perl v5.9 and beyond will be able to automatically quote v-strings
(which will become the recommended notation), but that is not possible in
earlier versions of Perl.  In other words:

  $version = new version "v2.5.4";	# legal in all versions of Perl
  $newvers = new version v2.5.4;	# legal only in Perl > v5.9 


=head2 Types of Versions Objects

There are three basic types of Version Objects:

=item * Ordinary versions - These are the versions that normal
modules will use.  Can contain as many subversions as required.
In particular, those using RCS/CVS can use the following code:

  $VERSION = new version (qw$Revision: 1.7 $)[1];

and the current RCS Revision for that file will be inserted 
automatically.  If the file has been moved to a branch, the
Revision will have three or more elements; otherwise, it will
have only two.  This allows you to automatically increment
your module version by using the Revision number from the primary
file in a distribution, see L<ExtUtils::MakeMaker/"VERSION_FROM">.

=item * Beta versions - For module authors using CPAN, the 
convention has been to note unstable releases with an underscore
in the version string, see L<CPAN>.  Beta releases will test as being
newer than the more recent stable release, and less than the next
stable release.  For example:

  $betaver = new version "12.3_1"; # must quote

obeys the relationship

  12.3 < $betaver < 12.4

As a matter of fact, if is also true that

  12.3.0 < $betaver < 12.3.1

where the subversion is identical but the beta release is less than
the non-beta release.

=item * Perl-style versions - an exceptional case is versions that
were only used by Perl releases prior to 5.6.0.  If a version
string contains an underscore immediately followed by a zero followed
by a non-zero number, the version is processed according to the rules
described in L<perldelta/Improved Perl version numbering system>
released with Perl v5.6.  As an example:

  $perlver = new version "5.005_03";

is interpreted, not as a beta release, but as the version 5.5.30,  NOTE
that the major and minor versions are unchanged but the subversion is
multiplied by 10, since the above was implicitely read as 5.005.030.

=head2 Replacement UNIVERSAL::VERSION

In addition to the version objects, this modules also replaces the core
UNIVERSAL::VERSION function with one that uses version objects for its
comparisons.  So, for example, with all existing versions of Perl, the
something like the following is an error:

	package vertest;
	$VERSION = 0.45;

	package main;
	use vertest 0.5;

even though those versions are meant to be read as 0.045 and 0.005 
respectively.  The UNIVERSAL::VERSION replacement function included
with this module makes that B<not> be an error, as it should.

=head1 EXPORT

None by default.

=head1 AUTHOR

John Peacock E<lt>jpeacock@rowman.comE<gt>

=head1 SEE ALSO

L<perl>.

=cut
