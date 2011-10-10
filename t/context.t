#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Plack::Request;

use_ok('Jet::Context');

ok (my $context = Jet::Context->instance, 'Create 1st instance');
ok (my $test = Jet::Test::Context->new, 'Create test instance');
is_deeply( $context->stash, {a => 1}, 'Stash is set in module');
ok(my $req = Plack::Request->new(env()), 'New plack request');
ok( $context->_request($req), 'Set context request');
ok( my $rest = $context->rest, 'Context rest');
is_deeply($rest->accept_types, ['text/html','application/xhtml+xml','application/xml','*/*'], 'Correct accept_types');
is($rest->type, 'HTML', 'Correct type');
is($rest->verb, 'GET', 'Correct verb');
isa_ok($rest->parameters, 'Hash::MultiValue', 'Parameters class');
is_deeply([ $rest->parameters->keys ], [], 'No parameters');

done_testing;

sub env {
	return {
          'psgi.multiprocess' => 1,
          'SCRIPT_NAME' => '',
          'psgix.session.options' => {
                                       'id' => '91e2723b158c5b0ffe5400bf1ae2a9fb05b62afa'
                                     },
          'PATH_INFO' => '/groups/rasmussen/kaare/',
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
          'plack.cookie.parsed' => {
                                     'plack_session' => '91e2723b158c5b0ffe5400bf1ae2a9fb05b62afa'
                                   },
          'psgix.session' => {
                               'user_id' => 'kaare'
                             },
          'SERVER_PORT' => 5000,
          'HTTP_COOKIE' => 'plack_session=91e2723b158c5b0ffe5400bf1ae2a9fb05b62afa',
          'REMOTE_ADDR' => '127.0.0.1',
          'SERVER_PROTOCOL' => 'HTTP/1.1',
          'psgi.errors' => *::STDERR,
          'REQUEST_URI' => '/groups/rasmussen/kaare/',
          'psgi.nonblocking' => '',
 #         'psgix.io' => bless( \*Symbol::GEN4, 'Net::Server::Proto::TCP' ),
          'plack.cookie.string' => 'plack_session=91e2723b158c5b0ffe5400bf1ae2a9fb05b62afa',
          'psgi.url_scheme' => 'http',
          'psgix.harakiri' => 1,
          'HTTP_HOST' => 'localhost:5000',
#          'psgi.input' => \*{'Starman::Server::$io'}
        };
}
package Jet::Test::Context;

use Jet::Context;

sub new {
	my $class = shift;
	my $config = Jet::Context->instance;
	$config->stash->{a} = 1;
};