use strict;
use warnings;

use Plack::Builder;

use Jet;

my $machine = Jet->new;
my $app = sub { $machine->run_psgi(@_) };

builder {
	enable "Plack::Middleware::Static",
		path => qr{^/(images|js|css)/}, root => './public/';
	$app;
};