#!perl -w
package version;

use 5.005_04;
use strict;

use vars qw(@ISA $VERSION $CLASS $STRICT $LAX *declare *qv);

$VERSION = 0.9905;
$CLASS = 'version';

require version::regex;
@ISA = qw'version::regex';

{
    local $SIG{'__DIE__'};
    eval "use version::vxs $VERSION";
    if ( $@ ) { # don't have the XS version installed
	eval "use version::vpp $VERSION"; # don't tempt fate
	die "$@" if ( $@ );
	push @ISA, "version::vpp";
	local $^W;
	*version::qv = \&version::vpp::qv;
	*version::declare = \&version::vpp::declare;
	*version::_VERSION = \&version::vpp::_VERSION;
	*version::vcmp = \&version::vpp::vcmp;
	*version::new = \&version::vpp::new;
	if ($] >= 5.009000) {
	    no strict 'refs';
	    *version::stringify = \&version::vpp::stringify;
	    *{'version::(""'} = \&version::vpp::stringify;
	    *{'version::(<=>'} = \&version::vpp::vcmp;
	    *version::parse = \&version::vpp::parse;
	}
    }
    else { # use XS module
	push @ISA, "version::vxs";
	local $^W;
	*version::declare = \&version::vxs::declare;
	*version::qv = \&version::vxs::qv;
	*version::_VERSION = \&version::vxs::_VERSION;
	*version::vcmp = \&version::vxs::VCMP;
	*version::new = \&version::vxs::new;
	if ($] >= 5.009000) {
	    no strict 'refs';
	    *version::stringify = \&version::vxs::stringify;
	    *{'version::(""'} = \&version::vxs::stringify;
	    *{'version::(<=>'} = \&version::vxs::VCMP;
	    *version::parse = \&version::vxs::parse;
	}
    }
}


1;
