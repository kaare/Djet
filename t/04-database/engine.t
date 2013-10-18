package Engine;

use 5.010;
use strict;
use warnings;
use Test::More;
use Test::MockModule;

use Jet::Starter;
use Jet::Request;
use Jet::Response;

{ package Test::Part1;

	use Moose::Role;
	with 'Jet::Part';
	no Moose::Role;

	sub init {
		warn "test init 1";
	}

	sub data {
		warn "test data 1";
	}

}

{ package Test::Part2;

	use Moose::Role;
	with 'Jet::Part';
	no Moose::Role;
	sub init {
		warn "test init 2";
	}

	sub data {
		warn "test data 2";
	}

}

{ package Test::Engine;

	use Moose;

	extends 'Jet::Engine';

	has parts => (
		traits	=> [qw/Jet::Trait::Engine/],
		is		=> 'ro',
		isa	   => 'ArrayRef',
		parts => [
			{'Test::Part1' => 'jet_part_1'},
			{'Test::Part2' => 'jet_part_2'},
		],
	);

	before jet_part_1_init => sub {
		my $self = shift;
		$self->stash->{init} = 'No init';
	};

	after jet_part_2_data => sub {
		my $self = shift;
		$self->stash->{data} = 'No data';
	};

	# sub go {
		# my $self = shift;
		# my $stash = {};
		# ok($self->engine->init, 'Init loop');
		# use Data::Dumper;
		# warn Dumper $self->engine->stash;
		# ok($self->engine->data, 'Data loop');
		# warn Dumper $self->engine->stash;
	# }
}
sub env {
       return {
          'psgi.multiprocess' => 1,
          'SCRIPT_NAME' => '',
          'PATH_INFO' => '/',
          'HTTP_ACCEPT' => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
          'REQUEST_METHOD' => 'GET',
          'psgi.multithread' => '',
          'HTTP_USER_AGENT' => 'Mozilla/5.0 (X11; Linux x86_64; rv:2.0.0) Gecko/20100101 Firefox/4.0',
          'QUERY_STRING' => '',
          'psgix.input.buffered' => 1,
          'HTTP_ACCEPT_LANGUAGE' => 'en-us,en;q=0.5',
          'HTTP_KEEP_ALIVE' => '115',
          'psgi.streaming' => 1,
          'psgi.version' => [
                              1,
                              1
                            ],
          'REMOTE_HOST' => '127.0.0.1',
          'psgi.run_once' => '',
          'SERVER_NAME' => '127.0.0.1',
          'HTTP_ACCEPT_ENCODING' => 'gzip, deflate',
          'HTTP_ACCEPT_CHARSET' => 'ISO-8859-1,utf-8;q=0.7,*;q=0.7',
          'SERVER_PORT' => 5000,
          'REMOTE_ADDR' => '127.0.0.1',
          'SERVER_PROTOCOL' => 'HTTP/1.1',
          'psgi.errors' => *::STDERR,
          'REQUEST_URI' => '/',
          'psgi.nonblocking' => '',
          'psgi.url_scheme' => 'http',
          'psgix.harakiri' => 1,
          'HTTP_HOST' => 'localhost:5000',
        };
}


$ENV{JET_APP_ROOT} = './t';
my $starter = Jet::Starter->new;
my $schema = $starter->schema;
my $env = shift;
my $request = Jet::Request->new(
	env => env(),
	schema => $schema,
);
my $config = $schema->config;
my $path = $request->request->path_info;
my $data_nodes = $schema->resultset('DataNode')->find_basenode($path);
my $stash = {request => $request};
my $response = Jet::Response->new(
	stash  => $stash,
	request => $request,
	data_nodes => $data_nodes,
);
my $basenode = $data_nodes->first;


ok(my $engine = Test::Engine->new(
	stash => $stash,
	request => $request,
	basenode => $basenode,
	response => $response,
), 'New engine');
ok($engine->stash->{$_} = $_, "Put value on stash for $_") for qw/init data render/;
is($engine->stash->{init}, 'init', 'Init stash OK');
ok($engine->init, 'Init');
is($engine->stash->{init}, 'No init', 'Init stash changed OK');
ok($engine->data, 'Data');
is($engine->stash->{data}, 'No data', 'Data stash changed OK');
ok($engine->render, 'Render');

done_testing;
