#!/usr/bin/perl -w
package version::AlphaBeta;

use 5.005_03;
use strict;
use version;
use Exporter;

use overload (
    '""'  => \&stringify,
    '<=>' => \&spaceship,
    'cmp' => \&spaceship,
);

use vars qw(@ISA $VERSION %IB %OB $TYPE);

@ISA = qw(Exporter version);

$VERSION = '0.03';

%IB = (
    'a' => -3,
    'b' => -2,
    'rc'=> -1,
    ''  => 0,
    'pl'=> 1
);

%OB = reverse %IB;

$TYPE = join( "|", grep { $_ } keys(%IB) );

# Preloaded methods go here.

sub new {
    my $proto  = shift;
    my $class  = ref($proto) || $proto;
    my $parent = $proto if ref($proto);
    my $ival   = shift; 

    my @value  = ( grep { defined $_ }
        ($ival =~
	    /^v?         # optional prefix
	     (\d+)	# Major
	     \.		# Seperator
	     (\d+)	# Minor
	     (?!\.)     # No seperator here
	     ($TYPE)?   # Type
	     (\d+)?	# Subversion
	    $/x)
    );

    die "Illegal version string format: \"$ival\""
	unless scalar(@value) >= 2  # something matched
	    and scalar(@value) <= 4;# but not too much

    $value[2] = $IB{
	(defined $value[2] ? $value[2] : "")
    }; 

    my $self = \@value;
    bless $self, $class;

    return $self;
}

sub stringify {
    my $self = shift;
    my @values = @$self;

    $values[2] = $OB{$values[2]} if defined $values[2];
    my $fmt = "%d.%d".
    	(defined $values[2] ? "%s" : "").
    	(defined $values[3] ? "%d" : "");
    return sprintf($fmt,@values);
}

sub spaceship {
    my ($left, $right, $swap) = @_;
    my $test;
    
    unless ( UNIVERSAL::isa($right, ref($left)) ) {
	$right = $left->new($right);
    }

    my $max = $#$left > $#$right ? $#$left : $#$right;

    for ( my $i=0; $i <= $max; $i++ ) {
	$test = $$left[$i] <=> $$right[$i];
	$test *= -1 if $swap;
	return $test if $test;
    }

    $test = $#$left <=> $#$right;
    $test *= -1 if $swap;

    return $test;
}

sub is_alpha {
    my $self = shift;

    return ($$self[2] == $IB{'a'});
}

sub is_beta {
    my $self = shift;

    return ($$self[2] == $IB{'b'});
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

=head2 OBJECT METHODS

This module provides two additional logical methods, apart from 
those already exported by the base version class.

=over 4

=item * is_alpha

Replacing the base method by the same name, this will return true
only if the version has an 'a' in the third position, i.e.

  $VERSION = new version::AlphaBeta "1.3a1";
  print $VERSION->is_alpha; # prints 1

=back

=over 4

=item * is_beta

A new method which supplements $obj->is_alpha:

  $VERSION = new version::AlphaBeta "1.3b3";
  print $VERSION->is_alpha; # prints 0
  print $VERSION->is_beta; # prints 1

=back

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
