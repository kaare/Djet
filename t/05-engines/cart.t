package Engine;

use 5.010;
use strict;
use warnings;
use Test::More;
use Plack::Test;
use HTTP::Request::Common;

use Djet::Starter;

use lib 't/lib';
use Test;

my $db_name = Test::db_name;
warn $db_name;
ok(qx{psql $db_name -f t/sql/$_.sql}, "Create $_ Djet test tables") for qw/cart/;

$ENV{DJET_APP_ROOT} = './t';
my $djet = Djet::Starter->new;

my $app = $djet->app;
my $test = Plack::Test->create($app);

my $res = $test->request(GET "/cart/");
like $res->content, qr{til levering};

done_testing;

=pod

# traditional - named params
test_psgi
    app => sub {
        my $env = shift;
        return [ 200, [ 'Content-Type' => 'text/plain' ], [ "Hello World" ] ],
    },
    client => sub {
        my $cb  = shift;
        my $req = HTTP::Request->new(GET => "http://localhost/hello");
        my $res = $cb->($req);
        like $res->content, qr/Hello World/;
    };

# positional params (app, client)
my $app = sub { return [ 200, [], [ "Hello "] ] };
test_psgi $app, sub {
    my $cb  = shift;
    my $res = $cb->(GET "/");
    is $res->content, "Hello";
};
=pod



use Djet::Starter;

use Djet::Shop::Cart;

my $starter = Djet::Starter->new;
my $model = $starter->model;
my $config = $model->config;
ok(my $cart = Djet::Shop::Cart->new(model => $model, uid => 1), 'New cart object');
ok($cart->add(sku => 'FOO', name => 'Foo Shoes', price => 5, quantity => 2), 'Add Foo Shoes');
is($cart->count, 1, 'One line');
is($cart->total, 10, 'Total is 10');

done_testing;
