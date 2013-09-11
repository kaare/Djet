package Jet::Basenode;

use 5.010;
use Moose;

use namespace::autoclean;

=head1 NAME

Jet::Basenode - The Base Jet Node

=head1 DESCRIPTION

=head1 ATTRIBUTES

=head2 schema

=cut

has schema => (
	isa => 'Jet::Schema',
	is => 'ro',
);

=head2 basetypes

=cut

has basetypes => (
	isa => 'Jet::Config::Basetypes',
	is => 'ro',
);

=head2 path

=cut

has path => (
	isa => 'Str',
	is => 'ro',
);

=head2 rows

The node data found for this node

=cut

has rows => (
	traits	=> ['Hash'],
	is	=> 'ro',
	isa	=> 'Jet::Schema',
	default	=> sub {
		my $self = shift;
		my $path = $self->path;
		$path =~ s|^(.*?)/?$|$1|; # Remove last character if slash
		return $self->schema->search(node_path => { '@>' => $path } }, {order_by => {-desc => 'nlevel(node_path)'} });
	},
);

=head2 basetype

The node's basetype

=cut

has basetype => (
	isa => 'Jet::Basetype',
	is => 'ro',
	default	=> sub {
		my $self = shift;
		my $request = $self->request;
		my $basedata = $self->rows->first;
		my %nodeparams = (
			schema => $request->schema,
			basetype => $request->basetypes->{$basedata->{basetype_id}},
		);
		# Save the remaining nodes on the stash
# Reenab	le this when find_basenode returns an array w/ the basenode and all ancestors again
#		$stash->{nodes}{$_->{node_id}} = Jet::Node->new(row => $_, stash => $stash) for @$nodedata;
		return Jet::Basenode->new(%nodeparams, row => $basedata);
}
);

__PACKAGE__->meta->make_immutable;

__END__

=head1 AUTHOR

Kaare Rasmussen, <kaare at cpan dot com>

=head1 BUGS 

Please report any bugs or feature requests to my email address listed above.

=head1 COPYRIGHT & LICENSE 

Copyright 2013 Kaare Rasmussen, all rights reserved.

This library is free software; you can redistribute it and/or modify it under the same terms as 
Perl itself, either Perl version 5.8.8 or, at your option, any later version of Perl 5 you may 
have available.
