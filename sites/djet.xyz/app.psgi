#!/usr/bin/env perl
use 5.010;
use strict;
use warnings;

use Plack::Builder;

use Djet;

my $djet = Djet->new;
my $session_handler = $djet->session_handler;

builder {
	enable 'Session', store => $session_handler;
	enable 'ConditionalGET';
#	enable 'Plack::Middleware::AccessLog::Timed', format => '%v %h %l %u %t \"%r\" %>s %b %D';
	enable 'Plack::Middleware::AccessLog::Timed', format =>  '%v %{X_Real_IP}i %l %u %t \"%r\" %>s %b %D';
	enable 'Image::Scale', path => qr{^/(img)/}, flags => { fit => 1 };
	enable 'Static', path => qr{^/css|fonts|images|js/}, root => './public/', pass_through => 1;
	enable 'Static', path => qr{^/css|fonts|images|js/}, root => '../../public/';
	enable 'Static', path => qr{^/img/}, root => './public/', pass_through => 1;
	enable 'Static', path => qr{^/img/}, root => '../Djet/public/';
	mount "/favicon.ico" => Plack::App::File->new(file => 'public/favicon.ico');
	mount "/" => $djet->app;
};

