use 5.010;
use strict;
use warnings;

use Plack::Builder;

use Jet;

my $machine = Jet->new;
my $app = sub { $machine->run_psgi(@_) };

sub check_pass {
	my( $username, $pass ) = @_;
	return $username eq $pass;
}

builder {
#	enable 'Debug',
#		panels =>[qw/ DBITrace Environment Memory ModuleVersions PerlConfig Response Timer/];
#	enable 'Debug::Profiler::NYTProf';
#	enable 'Debug::DBIProfile', profile => 2;
#	enable 'InteractiveDebugger';
#	enable 'Session',
#		store => 'File';
#	enable 'Auth::Form',
#		authenticator => \&check_pass;
	enable "Plack::Middleware::Static",
		path => qr{^/(images|js|css)/}, root => './public/';
	$app;
};