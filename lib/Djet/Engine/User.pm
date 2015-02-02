package Djet::Engine::User;

use 5.010;
use Moose;
use Encode qw/decode/;

extends 'Djet::Engine::Default';
with qw/
	Role::Pg::Roles
	Djet::Part::Log
	Djet::Part::Update::Node
	Djet::Part::List
/;

=head1 NAME

Djet::Engine::User

=head2 DESCRIPTION

List, create, update and view users.

=head1 METHODS

=head2 after init_data

Init the list part

=cut

before 'init_data' => sub {
	my $self = shift;
	if ($self->basenode->basetype->name eq 'user') {
		$self->stash->{user} = $self->basenode;
		return;
	}
	return $self->new_form if $self->rest_path eq 'new';

	$self->stash->{header_children} = $self->model->basetype_by_name('user')->datacolumns or die "No basetype: user";
	$self->add_search(parent_id => $self->basenode->node_id);
};

=head2 new_form

Display the form for a new user

=cut

sub new_form {
	my $self = shift;
	$self->set_limit(-1);
	my $model = $self->model;
	my $user_basetype = $model->basetype_by_name('user') or die "No basetype: user";

	$self->template($self->template_substitute($user_basetype->template));
	$self->stash_user($user_basetype) unless $self->stash->{user};
}

=head2 stash_user

Create a new user row and stash it

=cut

sub stash_user {
	my ($self, $user_basetype) = @_;
	my $user = $self->model->resultset('Djet::DataNode')->new({
		basetype_id => $user_basetype->id,
		parent_id => $self->basenode->id,
		datacolumns => {}
	});
	$self->stash->{user} = $user;
	$self->set_object($user);
	$self->is_new(1);
}

=head2 before post_is_create

This is processed when the contactform is submitted. A new "child" contactform is created, and the flow proceeds to
validation.

=cut

before 'post_is_create' => sub  {
	my $self = shift;
	return if $self->basenode->basetype->name eq 'user';

	my $model = $self->model;
	my $user_basetype = $model->basetype_by_name('user') or die "No basetype: user";

	$self->stash_user($user_basetype);
};

=head2 before edit_validation

Add check for existing role before validation (when creating new user)

Users are added to the group(s) defined in the "users" node

Here we check if the user can be added to any of the groups.

=cut

before 'edit_validation' => sub {
	my $self = shift;
	return unless $self->is_new;

	my $groups = $self->basenode->fields->roles->value;
	my $check_role = sub {
		my $name = pop;
		my $missing;
		for my $group (@$groups) {
			$missing = 1 if !$self->member_of(user => $name, group => $group);
		}
		return $missing;
	};
	$self->dfv->{constraint_methods}{name} = $check_role;
};

=head2 before edit_create

Add the role incl password

=cut

before 'edit_create' => sub {
	my ($self, $validation) = @_;
	my $valid_data = $validation->valid;
	my ($name, $password) = map {decode('utf-8', $valid_data->{$_}) } qw/handle password/;
	my $user = $self->create_role(role => $name, password => $password);
};

=head2 before get_input_data

This is for sure called inside the transaction block.

=cut

before 'get_input_data' => sub {
	my ($self, $validation)=@_;
	$validation->valid->{name} = $validation->valid->{handle};
	$validation->valid->{title} = $validation->valid->{username};
	$validation->valid->{part} = $validation->valid->{handle};
};

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
