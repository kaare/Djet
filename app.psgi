use 5.010;
use strict;
use warnings;

use Plack::Builder;

use Jet;

my $app = sub {
	my $env = shift;
	if ($env->{'psgix.session'}{user_id}) {
		my $machine = Jet->new;
		$machine->run_psgi($env, @_);
	} else {
		return [ 302, { 'Location' => '/login', }, [ ] ];
	}
};

sub check_pass {
	my( $username, $pass ) = @_;
	my $machine = Jet->new;
return 1;
	my $person = $machine->login($username, $pass);
	return unless defined $person;
	return {user_id => $username, redir_to => join '/', $person->{node_path}, ''};
}

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
	enable 'Auth::Form',
		authenticator => \&check_pass;
	enable 'Static',
		path => qr{^/(images|js|css)/}, root => './public/';
	$app;
};