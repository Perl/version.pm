#!/usr/bin/perl -w
package version::AlphaBeta;

use 5.006;
use strict;
use warnings;
use version;
use Exporter;

use overload (
    '""'  => \&_stringify,
    '<=>' => \&spaceship,
    'cmp' => \&spaceship,
);

use vars qw(@ISA $VERSION %IB %OB $TYPE);

@ISA = qw(Exporter version);

$VERSION = '0.01';

%IB = (
    'a' => 1,
    'b' => 2,
    'rc'=> 3,
    ''  => 4,
    'pl'=> 5
);

%OB = reverse %IB;

$TYPE = join( "|", grep { $_ } keys(%IB) );

# Preloaded methods go here.

sub new {
    my $proto  = shift;
    my $class  = ref($proto) || $proto;
    my $parent = $proto if ref($proto);
    my $ival   = shift; 

    my $value  = [ grep { defined $_ }
        ($ival =~
	    /^v?         # optional prefix
	     (\d+)	# Major
	     \.		# Seperator
	     (\d+)	# Minor
	     (?!\.)     # No seperator here
	     ($TYPE)?   # Type
	     (\d+)?	# Subversion
	    $/x)
    ];

    die "Illegal version string format: \"$ival\""
	unless scalar(@$value) >= 2  # something matched
	    and scalar(@$value) <= 4;# but not too much

    $value->[2] = $IB{
	(defined $value->[2] ? $value->[2] : "")
    }; 

    my $self = version->new('v'.join(".",@$value));
    bless $self, $class;

    return $self;
}

sub _stringify {
    my $self = shift;
    my @value = split /\./, $self->stringify();

    $value[2] = $OB{$value[2]} if defined $value[2];
    my $fmt = "v%d.%d".
    	(defined $value[2] ? "%s" : "").
    	(defined $value[3] ? "%d" : "");
    return sprintf($fmt,@value);
}

sub spaceship {
    my ($left, $right, $swap) = @_;
    
    unless ( UNIVERSAL::isa($right, ref($left)) ) {
	$right = $left->new($right);
    }

    return version::vcmp($left, $right,$swap);
}


1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

version::AlphaBeta - Use alphanumeric version objects

=head1 SYNOPSIS

  use version::AlphaBeta;
  $VERSION = new version::AlphaBeta "v1.2b";

=head1 ABSTRACT

  Derived class of version objects which permits use of specific
  alphanumeric version objects, patterned after the version strings
  used by many open source programs, like Mozilla.

=head1 DESCRIPTION

The base version objects only permit a sequence of numeric values
to be used, which is not how some software chooses to label their
version strings.  This module permits a specific sequence of alpha,
beta, release candidate, release, and patch versions to be specified
instead of strictly numeric versions.  Sorted in increasing order:

=over 2

  Version     Meaning
  1.3a        1.3 alpha release
  1.3b        1.3 beta release
  1.3b2       1.3 second beta release
  1.3rc       1.3 release candidate
  1.3rc2      1.3 second release candidate
  1.3         1.3 final release
  1.3p1       1.3 first patch release

=back

This module can be used as a basis for other subclasses of version
objects.  The global hash object %IB defines the acceptable non-numeric
version parameters:

  %IB = (
      'a' => 1,
      'b' => 2,
      'rc'=> 3,
      ''  => 4,
      'pl'=> 5
  );

which, if present at all, must be located in the third subversion.

=head2 EXPORT

None by default.

=head1 HISTORY

=over 8

=item 0.01

Original version; created by h2xs 1.22 with options

  --use-new-tests
	-b
	5.6.0
	-CXfn
	version::AlphaBeta

=back



=head1 SEE ALSO

L<version>

=head1 AUTHOR

John Peacock, E<lt>jpeacock@rowman.com<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2003 by John Peacock

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
