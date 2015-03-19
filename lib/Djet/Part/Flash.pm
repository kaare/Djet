package Djet::Part::Flash;

use 5.010;
use Moose::Role;
use namespace::autoclean;

requires qw/session/;

=head1 NAME

Djet::Part::Flash

=head1 DESCRIPTION

Handle passing of status (success and error) messages between screens of a web application.

=head1 SYNOPSIS

In MyDjetEngine.pm:

    with qw/
        Djet::Part::Flash
    /;

In the engine where you want to save a message for display on the next page:

   $self->set_status_msg("Deleted widget");

Or, to save an error message:

   $self->set_error_msg("Error deleting widget");

Then, in the engine where you want to use the message, you load the message back again:

        ...
        $self->load_status_msgs;
        ...

=head1 DESCRIPTION

There are a number of ways people commonly use to pass "status messages"
between screens in a web application.

=over 4

=item *

Using the stash: The stash only exists for a single request, so this
approach can leave the wrong URL in the user's browser.

=item *

Query parameters in the URL: This suffers from issues related to
long/ugly URLs and leaves the message displayed even after a browser
refresh.

Also it doesn't persist when it actually has to. Imagine you redirect to a page that 
redirects to the final destination. The message is lost!

=back

This role attempts to address these issues through the following mechanisms:

=over 4

=item *

Stores messages in the C<session> so that the application is free
to redirect to the appropriate URL after an action is taken.

=item *

Associates a random 8-digit "token" with each message, so it's completely
unambiguous what message should be shown in each window/tab.

=item *

Only requires that the token (not the full message) be included in the
redirect URL.

=item *

Automatically removes the message after the first time it is displayed.
That way, if users hit refresh in their browsers they only see the
messages the first time.

=back

=head1 METHODS

=head2 load_status_msgs

Load both messages that match the token parameter on the URL (e.g.,
http://myserver.com/widgits/list?flash=1234567890) into the stash
for display by the viewer.

This method is called in the default engine and the messages are put
on the stash automatically. It's a reasonable default; this is what you
want 99% of the time. It can be turned off for the small number of times
that's necessary.

=head1 METHODS

=head2 get_error_msg

A dynamically generated accessor to retrieve saved error messages

=head2 get_status_msg

A dynamically generated accessor to retrieve saved status messages

=head2 set_error_msg

A dynamically generated accessor to save error messages

=head2 set_status_msg

A dynamically generated accessor to save status messages

=cut

has 'messages' => (
	traits	=> ['Hash'],
	is		=> 'ro',
	isa	   => 'HashRef[Str]',
	default   => sub {
		my $self = shift;
		my $token = $self->flash_token;
		return $self->model->session->{flash}{$token} //= {};
	},
	lazy => 1,
	handles   => {
		set_error_msg	=> [set => 'error'],
		get_error_msg	=> [delete => 'error'],
		set_status_msg	=> [set => 'status'],
		get_status_msg	=> [delete => 'status'],
		has_no_messages => 'is_empty',
		num_messages	=> 'count',
		load_mesages	=> 'kv',
	},
	predicate => 'messages_touched',
);

=head2 flash_token

Returns a token to be used for the flash

=cut

has 'flash_token' => (
	is		=> 'ro',
	isa	   => 'Str',
	default   => sub {
    	my $token = sprintf( "%08d", int( rand(100_000_000) ) );
    	return $token;
	},
);

=head2 before redirect

The flash token will be added to the redirect uri

=cut

before 'redirect' => sub {
	my $self = shift;
	return unless $self->messages_touched;

	use URI;
	my $location = URI->new($self->response->location);
	$location->query_form($location->query_form, flash => $self->flash_token);
	$self->response->location($location->as_string);
};

no Moose::Role;

1;

#COPYRIGHT

