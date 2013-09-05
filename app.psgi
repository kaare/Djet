#!/usr/bin/env perl
use 5.010;
use strict;
use warnings;

use OX;

router as {
#	mount '/static' => "Plack::App::File", (
#	    root => 'static_root',
#	    encoding => literal('latin1'),
#	);
	mount '/' => "Jet", (
	);
};
