#!/usr/bin/env perl
use 5.010;
use strict;
use warnings;

use Plack::Builder;

use Djet::Starter;

my $djet = Djet::Starter->new;
my $session_handler = $djet->session_handler;

builder {
#	enable 'Debug',
#		panels =>[qw/ DBITrace Environment Memory ModuleVersions PerlConfig Response Timer/];
#	enable 'Debug::Profiler::NYTProf';
#	enable 'Debug::DBIProfile',
#		profile => 2;
#	enable 'InteractiveDebugger';
#	enable 'Auth::Form',
#		authenticator => \&check_pass;
	enable 'HTTPExceptions', rethrow => 1;
	enable 'Plack::Middleware::AccessLog::Timed',
		format => '%v %h %l %u %t \"%r\" %>s %b %D';
	enable 'Session', store => $session_handler;
	enable 'Static',
		path => qr{^/(fonts|images|js|css)/}, root => './public/';

	$djet->app;
};
