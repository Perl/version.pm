#!perl -w
package version;

use 5.005_04;
use strict;

use vars qw(@ISA $VERSION $CLASS $STRICT $LAX *declare *qv);

$VERSION = 0.81;

$CLASS = 'version';

# Define STRICT version parsing

my $INTEGER_PART = qr/
(?:
    0				# 0
  |				# or
    [1-9]			# 1-9 followed by
    [0-9]{0,}			# zero or more digits
)
/x;

my $DECIMAL_PART = qr/
(?:				# decimal part
    [.]				# literal decimal point
    [0-9]{1,}			# one or more digits
)
/x;

my $DECIMAL_VERSION = qr/
(?:
    ${INTEGER_PART}		# mandatory
    ${DECIMAL_PART}{0,1}	# optional
)
/x;

my $STRICT_DECIMAL_PART = qr/
(?:				# repeated part
    [.]				# literal decimal point
    [0-9]{1,3}			# followed by one to three digits
)
/x;

my $DOTTED_DECIMAL_VERSION = qr/
(?:
    v				# leading v required
    ${INTEGER_PART}		# mandatory decimal
    ${STRICT_DECIMAL_PART}{2,}	# repeating 2 or more times
)
/x;

$STRICT = qr/
(?:
    \A${DECIMAL_VERSION}\Z
  |
    \A${DOTTED_DECIMAL_VERSION}\Z
)
/x;

# Define LAX version parsing

my $ALPHA = qr/
(?:
    [_]				# literal underscore
    [0-9]{1,}			# followed by one or more digits
)
/x;

my $LAX_DOTTED_DECIMAL_VERSION = qr/
(?:
    (?:
	v			# leading v required
	${INTEGER_PART}
    )
  |				# or
    (?:
	v			# leading v required
	${INTEGER_PART}
	${DECIMAL_PART}{1,}	# one or more times
	${ALPHA}{0,1}		# with trailing optional alpha stanza
    )
  |				# or
    (?:
	(?!v)			# no leading v allowed
	${INTEGER_PART}
	${DECIMAL_PART}{2,}	# repeating two or more times
	${ALPHA}{0,1}		# with trailing optional alpha stanza
    )
)
/x;

my $LAX_DECIMAL_VERSION = qr/
(?:
    (?:
	${INTEGER_PART}
	${DECIMAL_PART}{0,1}	# optional
    )
  |				# or
    (?:
	${INTEGER_PART}
	${DECIMAL_PART}
	${ALPHA}{0,1}		# with trailing optional alpha stanza
    )
)
/x;

$LAX= qr/
(?:
    \A${LAX_DECIMAL_VERSION}\Z
  |
    \A${LAX_DOTTED_DECIMAL_VERSION}\Z
)
/x;

eval "use version::vxs $VERSION";
if ( $@ ) { # don't have the XS version installed
    eval "use version::vpp $VERSION"; # don't tempt fate
    die "$@" if ( $@ );
    push @ISA, "version::vpp";
    local $^W;
    *version::qv = \&version::vpp::qv;
    *version::declare = \&version::vpp::declare;
    *version::_VERSION = \&version::vpp::_VERSION;
    if ($] > 5.009001 && $] <= 5.010000) {
	no strict 'refs';
	*{'version::stringify'} = \*version::vpp::stringify;
	*{'version::(""'} = \*version::vpp::stringify;
	*{'version::new'} = \*version::vpp::new;
    }
}
else { # use XS module
    push @ISA, "version::vxs";
    local $^W;
    *version::declare = \&version::vxs::declare;
    *version::qv = \&version::vxs::qv;
    *version::_VERSION = \&version::vxs::_VERSION;
    if ($] > 5.009001 && $] < 5.010000) {
	no strict 'refs';
	*{'version::stringify'} = \*version::vxs::stringify;
	*{'version::(""'} = \*version::vxs::stringify;
    }
    elsif ($] == 5.010000) {
	no strict 'refs';
	*{'version::stringify'} = \*version::vxs::stringify;
	*{'version::(""'} = \*version::vxs::stringify;
	*version::new = \&version::vxs::new;
	*version::parse = \&version::vxs::parse;
    }

}

# Preloaded methods go here.
sub import {
    no strict 'refs';
    my ($class) = shift;

    # Set up any derived class
    unless ($class eq 'version') {
	local $^W;
	*{$class.'::declare'} =  \&version::declare;
	*{$class.'::qv'} = \&version::qv;
    }

    my %args;
    if (@_) { # any remaining terms are arguments
	map { $args{$_} = 1 } @_
    }
    else { # no parameters at all on use line
    	%args = 
	(
	    qv => 1,
	    'UNIVERSAL::VERSION' => 1,
	);
    }

    my $callpkg = caller();
    
    if (exists($args{declare})) {
	*{$callpkg."::declare"} = 
	    sub {return $class->declare(shift) }
	  unless defined(&{$callpkg.'::declare'});
    }

    if (exists($args{qv})) {
	*{$callpkg."::qv"} =
	    sub {return $class->qv(shift) }
	  unless defined(&{"$callpkg\::qv"});
    }

    if (exists($args{'UNIVERSAL::VERSION'})) {
	local $^W;
	*UNIVERSAL::VERSION 
		= \&version::_VERSION;
    }

    if (exists($args{'VERSION'})) {
	*{$callpkg."::VERSION"} = \&version::_VERSION;
    }
}

1;
