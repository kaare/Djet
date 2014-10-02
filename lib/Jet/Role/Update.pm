package Jet::Role::Update;

use MooseX::MethodAttributes::Role;
use List::MoreUtils qw{ any uniq };
use Encode qw/decode/;

use Jet::Data::Validator;

requires qw/stash_basic/;

=head1 NAME

Jet::Role::Update - generic methods for edit / create actions

=head1 DESCRIPTION

Handles edit functionality for Jet Engines

=head1 ATTRIBUTES

=head2 object

The object (node or basetype) to be updated or created

=cut

has object => (
	is => 'ro',
	isa => 'Object',
	writer => 'set_object',
	predicate => 'has_object',
);

=head2 is_new

True if the node to be updated is new. False if not

Default false

=cut

has is_new => (
	is => 'rw',
	isa => 'Bool',
	lazy => 1,
	default => 0,
);

=head2 dfv

The Data::Form::Validator init hash.

This is lazy_build in Jet::Role::Update::Node and Jet::Role::Update::Basetype
to reflect their respective requirements.

_build_dfv is also an obviuos place for method modifiers that will alter the
behaviour of the validator.

=cut

has dfv => (
	isa => 'HashRef',
	is => 'ro',
	lazy_build => 1,
	writer => 'set_dfv',
);

=head2 validator

The Basetype validator

=cut

has 'validator' => (
	isa => 'Jet::Data::Validator',
	is => 'ro',
	lazy_build => 1,
	reader => 'get_validator',
	writer => 'set_validator',
);

=head1 METHODS

=head2 BUILD

Tell the machine that we can handle html

=cut

after BUILD => sub {
	my $self = shift;
	$self->add_accepted_content_type( { 'application/x-www-form-urlencoded' => 'create_by_post' });
};

=head2 _build_validator

Build the validator for the node.

The validator is a Jet::Data::Validator and is used by (data)nodes to validate input

=cut

sub _build_validator {
	my $self= shift;
	return Jet::Data::Validator->new(dfv => $self->dfv);
}

=head2 allowed_methods

Allow POST for updating (Web::Machine)

=cut

sub allowed_methods {
	return [qw/GET HEAD POST/];
}

=head2 before view_page

Check if it's a delete request (GET w/ a 'delete' parameter)

=cut

before 'view_page' => sub {
	my $self = shift;
	my $request = $self->body->request;
	$self->set_base_object;
	if ($request->parameters->{delete}) {
		$self->delete_submit;
		return;
	}
};

=head2 post_is_create

Calls edit_submit and decides if continuing as process_post or create_path

  Continue with create_path if the validation and store process went well
  Continue with process_post if there was something wrong in the validation or store process

=cut

sub post_is_create {
	my $self = shift;
	$self->set_base_object;
	$self->edit_submit;
	return !defined $self->stash->{message};
}

=head2 process_post

Process the edit POST

=cut

sub process_post {
	my ($self) = @_;
	$self->stash_basic;
	my $request = $self->body->request;
	$self->_stash_defaults;
	$self->response->body($self->view_page);
}

=head2 create_path

Process the POST request for creating a node

=cut

sub create_path {
	my $self = shift;
	$self->stash_basic;
	$self->object->urify($self->stash->{domain_node});
}

=head2 create_by_post

We go here if a x-www-form-urlencoded post wants to create a new node

=cut

sub create_by_post { return \301; }

=head2 delete_resource

Handle a DELETE request

=cut

sub delete_resource {
	my ($self) = @_;
	$self->delete_submit;
}

=head2 delete_submit

Delete the object in question.

=cut

sub delete_submit {
	my ($self) = @_;
	my $object = $self->object;
	my $transaction = sub {
		$self->delete_object($self->object);
	};
	eval { $self->schema->txn_do($transaction) };
	my $error=$@;

	if ($error) {
		$self->config->log->debug($error);
		$self->stash->{message} = $error;
	} else {
		# XXX $self->flash->{notice} = $object->name . ' deleted.';
		$self->response->redirect($self->response->uri_for("/")); # XXX Where to redirect to? Might be parent ??
	}
}

=head2 delete_object

Delete the object inside a transaction

=cut

sub delete_object {
	my ($self, $object) = @_;
	$object->delete;
}

=head2 edit_submit

Controls the submit cycle

=cut

sub edit_submit {
	my ($self) = @_;
	my $validation = $self->edit_validation;

	if ($validation->success) {
		my $transaction = sub {
			if ($self->is_new) {
				my $object = $self->edit_create($validation);
				return unless ref $object; # local edit_create may choose not to create a new object

				$self->set_object($object);
			} else {
				$self->edit_update($validation);
			}
		};

		my $error = $self->edit_submit_handle_transaction($transaction);
		if (!$error) {
			$self->object->discard_changes;
			$self->edit_updated($validation);
		} else {
			$self->edit_failed_update($validation, $error);
		}
	} else {
		$self->edit_failed_validation($validation);
	}
}

=head2 edit_submit_handle_transaction

The actual transaction.

=cut

sub edit_submit_handle_transaction {
	my ($self, $transaction) = @_;
	my $rs;
	eval {
		$rs = $self->schema->txn_do($transaction);
	};
	return $@;
}

=head2 edit_validation

Performs the validation with translation from fieldname to item->name

project and user components save the parameter in _text

=cut

sub edit_validation {
	my $self = shift;

	eval { my $ralidator = $self->get_validator; };
	my $validator = $self->get_validator;
	my $params = $self->body->request->body_parameters;
	return $validator->validate($params);
}

=head2 edit_failed_validation

Is called if the validation failed

=cut

sub edit_failed_validation {
	my ($self, $validation)=@_;
	my %msgs = %{ $validation->msgs };
	$self->stash->{msgs} //= {};
	@{ $self->stash->{msgs} }{ keys %msgs } = values %msgs;

	$self->log->debug("Failed validation:\n\t" . join ("\n\t" , map {$_ . ' => ' . $msgs{$_}} keys %msgs)) if %msgs;
	my $node_type = $self->get_base_name;
	my $error = "Could not save $node_type information - see detailed information by positioning your mouse over the fields marked with orange background (same as this box) in the table below:";
	$self->log->error($error);
	$self->stash->{message} ||= $error;
}

=head2 edit_update

Update the object. Called from within the transaction

=cut

sub edit_update {
	my ($self, $validation)=@_;
	my $data = $self->get_input_data($validation);
	my $object = $self->object;
	$object->update($data);
	$object->discard_changes; # Necessary to keep db and dbic in sync
}

=head2 edit_create

Create the node from validation results. Called from within the transaction

=cut

sub edit_create {
	my ($self, $validation)=@_;
	my $data = $self->get_input_data($validation);
	if ($self->has_object) {
		$self->object->$_($data->{$_}) for keys %$data;
	}
	$data->{name} ||= $data->{title};
	my $object = $self->has_object ? $self->object : $self->get_resultset->new($data);
	$object->datacolumns($data->{datacolumns});
	$object->insert;
	$object->update($data);
	return $object;
}

=head2 get_input_data

Get the data from the form

=cut

sub get_input_data {
	my ($self, $validation)=@_;
	my $colnames = $self->get_colnames;
	my $input_data = $validation->valid;
	$input_data->{$_} = decode('utf-8', $input_data->{$_}) for keys %$input_data;
	my $data = { map { $_ => delete $input_data->{$_} } grep {$input_data->{$_}} @$colnames };
	my $edit_cols = $self->edit_cols;
	$data->{$_} = $self->$_($input_data, $data) for @$edit_cols; # special columns handling
	return $data;
}

=head2 edit_updated

Called if the update succeeds. Does nothing.

The validation object is passed here in case any method modifier wants to use it.

=cut

sub edit_updated {
	my ($self, $validation)=@_;
}

=head2 edit_failed_update

Called if the update failed

=cut

sub edit_failed_update {
	my ($self, $validation, $error)=@_;
	die "Transaction AND Rollback failed!" if ($error =~ /Rollback failed/);

	$self->stash->{message} = $error;
	$self->log->debug($error);
	$self->stash->{title}='Could not update ' . $self->object->title;
}

sub _stash_defaults {
	my ($self) = @_;
	my $request = $self->body->request;
	$self->stash->{defaults} = $request->parameters->as_hashref;
	while (my ($fieldname, $upload) = each %{ $request->uploads }) {
		$self->stash->{defaults}{$fieldname} = $upload->filename;
	}
}

=head2 find_rows_from_params

Works together with the across template to allow a row editing functionality.

Group the parameter values into rows and return as a list

=cut

sub find_rows_from_params {
	my ($self, $prefix, $params) = @_;
	my @list;
	for my $key (keys %{ $params }) {
		if ($key =~ /$prefix\_(\d+)_(.+)/) {
			my $rowno = $1;
			my $name = $2;
			$list[$rowno]{$name} = $params->{$key};
		}
	}
	return \@list;
}

=head2 get_colnames

Get the colnames of the object

=cut

sub get_colnames {
	my $self = shift;
	my $edit_cols = $self->edit_cols;
	return [ grep {my $colname = $_;!any {$colname eq $_} @$edit_cols, qw/id created modified/} $self->object->result_source->columns ];
}

1;
