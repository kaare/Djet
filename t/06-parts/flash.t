
use 5.010;
use strict;
use warnings;
use Test::More;

{ package Flash;
	use Moose;

	has 'session' => (
		isa => 'HashRef',
		is => 'ro',
		default => sub { {} },
	);

	with 'Djet::Part::Flash';

	sub redirect {}
}

my %msgs = (
	error => 'Stoopeed ms Take',
	status => '1 and two',
);

ok(my $flash = Flash->new, 'New flash');

ok($flash->set_error_msg($msgs{error}), 'Set error');
is($flash->num_messages, 1, 'One message');
is($flash->get_error_msg, $msgs{error}, 'Get error');
is($flash->num_messages, 0, 'No messages');

ok($flash->set_status_msg($msgs{status}), 'Set status');
is($flash->num_messages, 1, 'One message');
is($flash->get_status_msg, $msgs{status}, 'Get status');
is($flash->num_messages, 0, 'No messages');

ok(my $token = $flash->flash_token, 'Flash token');

done_testing;
