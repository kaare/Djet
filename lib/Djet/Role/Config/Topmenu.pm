package Jet::Role::Config::Topmenu;

use 5.010;
use Moose::Role;
use namespace::autoclean;

=head1 NAME

Jet::Role::Config::Topmenu - topmenu for config 

=head1 ATTRIBUTES

=cut

=head1 METHODS

=head2 topmenu

Return the topmenu (an arrayref)

=cut

sub topmenu {
	my ($self, $is_basetype) = @_;
	return [
		{
			name => 'nodes',
			title => 'Nodes',
			link => '/jet/config',
			active => !$is_basetype,
		},
		{
			name => 'basetype',
			title => 'Basetypes',
			link => '/jet/config/basetype',
			active => $is_basetype,
		},
	];
}

no Moose::Role;

1;

# COPYRIGHT

__END__
