
use 5.010;
use strict;
use warnings;
use Test::More;
use Test::Exception;

use Jet::Starter;
use Jet::Request;
use Jet::Response;

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
my $request = Jet::Request->new(
	env => env(),
	schema => $schema,
);
my $config = $schema->config;
my $path = $request->request->path_info;
my $data_nodes = $schema->resultset('DataNode')->find_basenode($path);
my $basenode = $data_nodes->first;
my $stash = {request => $request};
ok(my $response = Jet::Response->new(
	stash  => $stash,
	request => $request,
	data_nodes => $data_nodes,
	basenode => $basenode,
), 'New response object');

throws_ok { $response->redirect('somewhere') } qr/302 Found/, 'Redirect';
my $exception = $@;
is($exception->status_code, 302, '302 status code');
is($exception->location, 'somewhere', 'Redirect location');
is($exception->reason, 'Found', 'Redirect reason');

is($response->uri_for('somehow'), 'http://localhost:5000/somehow', 'uri_for');

done_testing;
