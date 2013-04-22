use 5.010;
use strict;
use warnings;

use Plack::Builder;
use CHI;

use Jet;
use Jet::Config;
use Jet::Request;
use Jet::Stuff;

our $config;
our $schema;
our $cache;
our $basetypes;
our $renderers;
our @roles;

my $app = sub {
	my $env = shift;
	if (1 || $env->{'psgix.session'}{user_id}) {
		my $request = Jet::Request->new(
			env => $env,
			config => $config,
			schema => $schema,
			cache  => $cache,
			basetypes => $basetypes,
			renderers => $renderers,
		);
		my $machine = @roles ?
			Jet->with_traits(@roles)->new(request => $request) :
			Jet->new(request => $request);
		$machine->run_psgi(@_);
	} else {
		return [ 302, { 'Location' => '/login', }, [ ] ];
	}
};

sub check_pass {
	my( $username, $pass ) = @_;
	my $person = login($username, $pass);
	return unless defined $person;
	return {user_id => $username, redir_to => join '/', $person->{node_path}, ''};
}

sub login {
	my ($login, $pwd) = @_;
	my $userbasetype = $schema->find_basetype({name => 'person'});
#	my $person = $schema->find_node({ basetype_id => $userbasetype->{id}, userlogin =>  $login, password => $pwd  });
	my $person = $schema->find_node({ basetype_id => $userbasetype->{id}  });
return 1;
	return unless $person;
	return $person->[0];
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


=head2 BEGIN

Build the Jet with roles

=cut

	# Init "Class Attributes"
	my $path = $INC{'Jet.pm'};
	$path =~ s|lib/+Jet.pm||;
	my $jet_root = $path;
	my $configbase = 'etc/';
	$config = Jet::Config->new(base => $configbase);
	my @connect_info = @{ $config->jet->{connect_info} };
	my %connect_info;
	$connect_info{$_} = shift @connect_info for qw/dbname username password connect_options/;
	$schema = Jet::Stuff->new(%connect_info);
	$basetypes = $schema->get_expanded_basetypes;
	$cache = CHI->new( %{ $config->jet->{cache} } );
	do {
		my $classname = "Jet::Render::$_";
		eval "require $classname" or die $@;
		$renderers->{lc $_} = $classname->new(
			jet_root => $jet_root,
			config => $config,
		);
	} for qw/Html/;

	# Roles
	my $role_config = $config->options->{Jet}{role};

	if ($role_config) {
		@roles = ref $role_config ? @{ $role_config } : ($role_config);
	}

	$app;
};