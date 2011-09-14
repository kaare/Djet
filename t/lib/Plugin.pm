package Plugin;

use 5.010;
use strict;
use warnings;
use Test::More;
use Test::MockModule;

use base 'Test::Class';

sub plugin : Test(7) {
	my $self = shift;
	# Setup mock module
	my $mockrequest = Test::MockModule->new('Plack::Request');
	$mockrequest->mock('param', sub {
		return 'POST';#{ x => 1 };
	});
	use_ok('Plack::Request');
	my $mockrest = Test::MockModule->new('Jet::Context::Rest');
	$mockrest->mock('verb', sub {
		return 'POST';
	});
	$mockrest->mock('parameters', sub {
		return {
			child_id => 2,
			albumname => 'alabuma',
		};
	});
	use_ok('Jet::Context::Rest');
	my $mockcontext = Test::MockModule->new('Jet::Context');
	$mockcontext->mock('rest', sub {
		return Jet::Context::Rest->new;
	});
	$mockcontext->mock('stash', sub {
		return {
			one => 1,
			two => 2,
			nodes => 'parents',
			no_nodes => 'children',
		}
	});
	use_ok('Jet::Context');
	my $c = Jet::Context->instance;
	my $req = Plack::Request->new({});
	$c->_request($req);
	# Start testing
	use_ok('Jet::Plugin');
	my $params = {
		plugin => 'Test::Plugin',
		content => {
			child_id => 'photo_id',
			names => {
					albumname => 'albumname',
					part => 'albumname',
					title => 'albumname',
				},
		},
		static => {
			method => 'children',
			params => {base_type => 'photoalbum'},
			name => 'groupalbums',
		},
		stash => {
			nodes => 'parents',
			numbers => [qw/one two/],
		},
	};
	ok(my $plugin = Jet::Plugin->new(params => $params), 'New plugin');
	isa_ok($plugin, 'Jet::Plugin', 'Correct class');
	my $expected = {
		params => {
			base_type => 'photoalbum'
		},
		names => {
			part => 'alabuma',
			albumname => 'alabuma',
			title => 'alabuma'
		},
		numbers => {
			one => 1,
			two => 2
		},
		name => 'groupalbums',
		child_id => 2,
		method => 'children',
		nodes => 'parents'
	};
	is_deeply($plugin->parameters, $expected, 'Plugin parameters are correct');
};

1;