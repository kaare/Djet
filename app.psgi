#!/usr/bin/env perl
use 5.010;
use strict;
use warnings;

use Plack::Builder;

use Jet::Starter;

my $jet = Jet::Starter->new;

builder {
#	enable 'Debug',
#		panels =>[qw/ DBITrace Environment Memory ModuleVersions PerlConfig Response Timer/];
#	enable 'Debug::Profiler::NYTProf';
#	enable 'Debug::DBIProfile',
#		profile => 2;
#	enable 'InteractiveDebugger';
	enable 'Plack::Middleware::AccessLog::Timed',
		format => '%v %h %l %u %t \"%r\" %>s %b %D';
	enable 'Session',
		store => 'File';
#	enable 'Auth::Form',
#		authenticator => \&check_pass;
	enable 'Static',
		path => qr{^/(images|js|css)/}, root => './public/';

	$jet->app;
};
