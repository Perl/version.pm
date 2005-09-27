
package version::vpp;
use strict;

use Exporter ();
use vars qw ($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS @REGEXS);
$VERSION     = 0.49;
@ISA         = qw (Exporter);
#Give a hoot don't pollute, do not export more than needed by default
@EXPORT      = qw (qv);
@EXPORT_OK   = qw ();
%EXPORT_TAGS = ();

push @REGEXS, qr/
	^v	# leading 'v'
	(\d*)	# major revision not required
	\.	# requires at least one decimal
	(?:(\d+)\.?){1,}
	/x;

local $^W; # shut up the 'redefined' warning for UNIVERSAL::VERSION

use overload (
    '+0'   => \&numify,
    '""'   => \&stringify,
    'cmp'  => \&vcmp,
    '<=>'  => \&vcmp,
);

sub new
{
	my ($class, $value) = @_;
	my $qv = 0;

	my $self = bless ({}, ref ($class) || $class);

	return ($self) unless $value;

	# First validate the input for sanity
	die "multiple underscores"
	  if $value =~ /^[\d.]+_[\d.]+_[\d.]+/;

	die "underscores before decimal"
	  if $value =~ /^[\d.]+_\d+\./;

	$value =~ /^\s*(v?)(\d+\.)?(\d+\.)?/;
	if ( $1 or $3 ) # explicit or implicit vstring 
	{
	    $self->{qv} = 1;
	    $qv = 1;
	}

	if ( $value =~ /\.(\d+)_/ )
	{
	    $self->{alpha} = 1;
	    if ( $qv ) {
		$value =~ tr/_/./; # underscores are treated like decimals
	    }
	    else {
		$self->{width} = length($1); # only valid for numeric-style
		$value =~ tr/_//d; # underscores are ignored
	    }
	}

	$value =~ /^\s*v?(\d*)\.?/g;
	my $term = int($1+0);
	push @{$self->{version}}, $term;
	
	while ( $value =~ /(\d{1,3})([._]?)/g)
	{
	    $term = int($1+0);
	    if ( $qv ) {
		push @{$self->{version}}, $term;
	    }
	    else {
		push @{$self->{version}}, ($term * 10**(3-length($1)));
	    }
	}

	if ( $qv ) {
	    while ( $#{$self->{version}} < 2 ) {
	    	push @{$self->{version}}, 0;
	    }
	}

	return ($self);
}

sub numify 
{
    my ($self) = @_;
    my $width = $self->{width} || 3;
    my $alpha = $self->{alpha} || "";
    my $len = $#{$self->{version}};
    my $digit = $self->{version}[0];
    my $string = sprintf("%d.", $digit );

    for ( my $i = 1 ; $i < $len ; $i++ ) {
	$digit = $self->{version}[$i];
	if ( $width < 3 ) {
	    my $denom = 10**(3-$width);
	    my $quot = int($digit/$denom);
	    my $rem = $digit - ($quot * $denom);
	    $string .= sprintf("%0".$width."d_%d", $quot, $rem);
	}
	else {
	    $string .= sprintf("%03d", $digit);
	}
    }

    if ( $len > 0 ) {
	$digit = $self->{version}[$len];
	if ( $alpha && $width == 3 ) {
	    $string .= "_";
	}
	$string .= sprintf("%0".$width."d", $digit);
    }
    else # $len = 0
    {
	$string .= sprintf("000");
    }

    return $string;
}

sub normal 
{
    my ($self) = @_;
    my $alpha = $self->{alpha} || "";
    my $len = $#{$self->{version}};
    my $digit = $self->{version}[0];
    my $string = sprintf("v%d", $digit );

    for ( my $i = 1 ; $i < $len ; $i++ ) {
	$digit = $self->{version}[$i];
	$string .= sprintf(".%d", $digit);
    }

    if ( $len > 0 ) {
	$digit = $self->{version}[$len];
	if ( $alpha ) {
	    $string .= sprintf("_%0d", $digit);
	}
	else {
	    $string .= sprintf(".%0d", $digit);
	}
    }

    return $string;
}

sub stringify
{
    my ($self) = @_;
    if ( exists $self->{qv} ) {
	return $self->normal;
    }
    else {
	return $self->numify;
    }
}

sub vcmp
{
    require UNIVERSAL;
    my ($left,$right,$swap) = @_;
    my $class = ref($left);
    unless ( UNIVERSAL::isa($right, $class) ) {
	$right = $class->new($right);
    }
    my $l = $#{$left->{version}};
    my $r = $#{$right->{version}};
    my $m = $l < $r ? $l : $r;
    my $lalpha = $left->is_alpha;
    my $ralpha = $right->is_alpha;
    my $retval = 0;
    my $i = 0;
    while ( $i <= $m && $retval == 0 ) {
	$retval = $left->{version}[$i] <=> $right->{version}[$i];
	$i++;
    }

    # tiebreaker for alpha with identical terms
    if ( $retval == 0 
	&& $l == $r 
	&& $left->{version}[$m] == $right->{version}[$m]
	&& ( $lalpha || $ralpha ) ) {

	if ( $lalpha && !$ralpha ) {
	    $retval = -1;
	}
	elsif ( $ralpha && !$lalpha) {
	    $retval = +1;
	}
    }

    # possible match except for trailing 0's
    if ( $retval == 0 && $l != $r ) {
	if ( $l < $r ) {
	    while ( $i <= $r && $retval == 0 ) {
		if ( $right->{version}[$i] != 0 ) {
		    $retval = -1; # not a match after all
		}
		$i++;
	    }
	}
	else {
	    while ( $i <= $l && $retval == 0 ) {
		if ( $left->{version}[$i] != 0 ) {
		    $retval = -1; # not a match after all
		}
		$i++;
	    }
	}
    }

    return $retval;  
}

sub is_alpha {
    my ($self) = @_;
    return (exists $self->{alpha});
}

sub qv {
    my ($class, $value) = @_;
    $value = 'v'.$value unless $value =~ /^v/;
    return $class->new($value);
}

1; #this line is important and will help the module return a true value
__END__
