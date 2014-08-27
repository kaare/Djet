package Jet::Engine::Contactform;

use 5.010;
use Moose;

extends 'Jet::Engine::Default';
with qw/Jet::Role::Log Jet::Role::Update::Node/;

=head1 NAME

Jet::Engine::Contactform - Search Engine

=head1 METHODS

=head2 init_data


=cut

after 'init_data' => sub  {
	my $self = shift;
	my $schema = $self->schema;
	my $basetype = $schema->basetype_by_name('contactform') or die "No basetype: contactform";
	my $contactform;
	if ($self->basenode->basetype_id == $basetype->id) {
		$contactform = $self->basenode;
		$self->stash->{template_display} = 'view';
	} else {
		$contactform = $self->schema->resultset('Jet::DataNode')->new({basetype_id => $basetype->id, datacolumns => {}});
	}
	$self->stash->{contactform} = $contactform;
};

=head2 process_post


=cut

before 'process_post' => sub  {
	my $self = shift;
	my $schema = $self->schema;
	my $basetype = $schema->basetype_by_name('contactform') or die "No basetype: contactform";
	my $contactform = $self->schema->resultset('Jet::DataNode')->new({
		parent_id => $self->basenode->id,
		basetype_id => $basetype->id,
		datacolumns => {},
		name => 'contactform',
		title => 'contactform',
	});
	$self->set_object($contactform);
	$self->stash->{contactform} = $contactform;
	$self->is_new(1);
};

=head2 before edit_updated

Send email

=cut

before 'edit_updated' => sub {
	my ($self, $validation)=@_;
	eval { $self->send_mail };
	$self->schema->log->error("Couldn't send email: $@") if $@;
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
