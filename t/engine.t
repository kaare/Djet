package Engine;

use 5.010;
use strict;
use warnings;
use Test::More;
use Test::MockModule;

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
		traits	=> [qw/Jet::Trait::Partname/],
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

ok(my $engine = Test::Engine->new, 'New engine');
ok($engine->stash->{$_} = $_, "Put value on stash for $_") for qw/init data render/;
is($engine->stash->{init}, 'init', 'Init stash OK');
ok($engine->init, 'Init');
is($engine->stash->{init}, 'No init', 'Init stash changed OK');
ok($engine->data, 'Data');
is($engine->stash->{data}, 'No data', 'Data stash changed OK');
ok($engine->render, 'Render');

done_testing;
