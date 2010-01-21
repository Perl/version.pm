#!perl -w
package version;

use 5.005_04;
use strict;

use vars qw(@ISA $VERSION $CLASS $STRICT $LAX *declare *qv);

$VERSION = '0.80';
$VERSION = eval $VERSION;

$CLASS = 'version';

# Define STRICT version parsing

my $DECIMAL_VERSION = '
(?:
    (?: 		# integer part
	0(?=[.])	# 0 but only if followed by a period
      |			# or
	[1-9]		# 1-9 followed by
	[0-9]*		# zero or more digits
    )
    (?:			# decimal part
	[.]		# literal decimal point
	[0-9]+		# one or more digits
    )?			# optional
)';

my $DOTTED_DECIMAL_VERSION = '
(?:
    v			# leading v required
    (?:			# integer part
	0(?=[.])	# 0 but only if followed by a period
      |			# or
	[1-9]		# 1-9 followed by
	[0-9]*		# zero or more digits
    )
    (?:			# repeated part
	[.]		# literal decimal point
	[0-9]{1,3}	# followed by one to three digits
    ){2,}		# repeating 2 or more times
)';

$STRICT = qr/(?:${DECIMAL_VERSION}|${DOTTED_DECIMAL_VERSION})/x;

# Define LAX version parsing

my $ALPHA = '
(?:
    [_]			# literal underscore
    [0-9]{1,}		# followed by one or more digits
)';

my $LAX_DOTTED_DECIMAL_VERSION = '
(?:
    (?:
	v		# leading v required
	(?:		# integer part
	    [0-9]+	# zero or more digits
	)
	(?:		# repeated part
	    [.]		# literal decimal point
	    [0-9]{1,}	# followed by one or more digits
	){0,}		# repeating zero or more times
    )
  |	# or
    (?:
	v		# leading v required
	(?:		# integer part
	    [0-9]+	# zero or more digits
	)
	(?:		# repeated part
	    [.]		# literal decimal point
	    [0-9]{1,}	# followed by one or more digits
	){1,}		# repeating one or more times
	${ALPHA}*	# with trailing optional alpha stanza(s)
    )
  |	# or
    (?:
	(?!v)		# no leading v
	(?:		# integer part
	    0(?=[.])	# 0 but only if followed by a period
	  |		# or
	    [1-9]	# 1-9 followed by
	    [0-9]*	# zero or more digits
	)
	(?:		# repeated part
	    [.]		# literal decimal point
	    [0-9]{1,}	# followed by one or more digits
	){2,}		# repeating two or more times
	${ALPHA}*	# with trailing optional alpha stanza(s)
    )
)
';

my $LAX_DECIMAL_VERSION = '
(?:
    (?:
	(?: 		# integer part
	    0(?=[.])	# 0 but only if followed by a period
	  |		# or
	    [1-9]	# 1-9 followed by
	    [0-9]*	# zero or more digits
	)
	(?:		# decimal part
	    [.]		# literal decimal point
	    [0-9]+	# one or more digits
	)?		# optional
    )
  |	# or
    (?:
	(?: 		# integer part
	    0(?=[.])	# 0 but only if followed by a period
	  |		# or
	    [1-9]	# 1-9 followed by
	    [0-9]*	# zero or more digits
	)		# mantissa required
	(?:		# decimal part
	    [.]		# literal decimal point
	    [0-9]+	# one or more digits
	)		# required
	${ALPHA}*	# with trailing optional alpha stanza(s)
    )
)
';

$LAX= qr/(?:${LAX_DECIMAL_VERSION}|${LAX_DOTTED_DECIMAL_VERSION})/x;

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
