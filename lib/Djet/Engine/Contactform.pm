package Djet::Engine::Contactform;

use 5.010;
use Moose;

extends 'Djet::Engine::Default';
with qw/
	Djet::Part::Flash
	Djet::Part::Log
	Djet::Part::Update::Node
/;

=head1 NAME

Djet::Engine::Contactform

=head2 DESCRIPTION

A contactform where the user enters some basic information and a comment. This data is saved in a new node, and emailed to both the site admin and the user self.

Based on the node update role, it includes validation as chosen for the individual fields, and all edit navigation is controlled there.

=head1 METHODS

=head2 before set_base_object

Will create a new empty contactform if it's a "parent" (contactforms) basetype. If it's a "child" contactform, will display it.

=cut

after 'set_base_object' => sub  {
	my $self = shift;
	my $model = $self->model;
	my $basetype = $model->basetype_by_name('contactform') or die "No basetype: contactform";

	my $contactform;
	if ($self->basenode->basetype_id == $basetype->id) {
		$contactform = $self->basenode;
		$self->stash->{template_display} = 'view';
	} else {
		$contactform = $self->model->resultset('Djet::DataNode')->new({
			basetype_id => $basetype->id,
			parent_id => $self->basenode->id,
			datacolumns => {}
		});
		$self->set_object($contactform);
		$self->is_new(1);
	}
	$self->stash->{contactform} = $contactform;
};

=head2 before process_post

This is processed when the contactform is submitted. A new "child" contactform is created, and the flow proceeds to
validation.

=cut

before 'process_post' => sub  {
	my $self = shift;
	my $model = $self->model;
	my $basetype = $model->basetype_by_name('contactform') or die "No basetype: contactform";

	my $contactform = $self->model->resultset('Djet::DataNode')->new({
		parent_id => $self->basenode->id,
		basetype_id => $basetype->id,
		datacolumns => {},
	});
	$self->set_object($contactform);
	$self->stash->{contactform} = $contactform;
	$self->is_new(1);
};


before 'get_input_data' => sub {
	my ($self, $validation)=@_;
	$validation->valid->{name} = 'Contactform';
	$validation->valid->{title} = $validation->valid->{name};
};


=head2 before edit_updated

Send email to the admin and the user if the "child" contactform was actually created.

=cut

before 'edit_updated' => sub {
	my ($self, $validation)=@_;
	$self->set_status_msg($self->basenode->fields->receipt_msg->value);
	eval { $self->send_mail };
	$self->model->log->error("Couldn't send email: $@") if $@;
};

=head2 send_mail

Actually send the email

=cut

sub send_mail {
	my $self = shift;
	my $mailer = $self->mailer;
	my $base_fields = $self->basenode->fields;
	my $in_fields = $self->object->fields;
	my @to = $base_fields->recipient->value, $in_fields->email->value;
	$self->stash->{template_display} = 'view';
	$self->object->discard_changes;
	$self->stash->{contactform} = $self->object;
	$mailer->send(
		template => $base_fields->template->value,
		to => \@to,
		from => $base_fields->from->value,
	);
}

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
