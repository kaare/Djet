package Jet::Stuff::Row;

use 5.010;
use Moose;

with 'Jet::Role::Log';

=head1 NAME

Jet::Stuff::Row - Row Class for Jet::Stuff

=head1 DESCRIPTION

This is the Row class for L<Jet::Stuff>.

=head1 SYNOPSIS

  my $row = Your::Model->search('user',{})->result->next;

=over

=item my $row = $row->next();

Get next row data.

=item my @ary = $row->all;

Get all row data in array.

=back

=head1 ATTRIBUTES

=cut

has 'row_data' => (
	traits    => ['Hash'],
	is        => 'ro',
	isa       => 'HashRef',
	default   => sub { {} },
	handles   => {
		set_column     => 'set',
		get_column     => 'get',
		has_no_columns => 'is_empty',
		num_columns    => 'count',
		delete_column  => 'delete',
		get_columns    => 'kv',
	},
);
has 'typetable'     => (
	isa => 'HashRef',
	is => 'ro',
);

__PACKAGE__->meta->make_immutable;

__END__

=head1 AUTHOR

Kaare Rasmussen, <kaare at cpan dot com>

=head1 BUGS 

Please report any bugs or feature requests to my email address listed above.

=head1 COPYRIGHT & LICENSE 

Copyright 2011 Kaare Rasmussen, all rights reserved.

This library is free software; you can redistribute it and/or modify it under the same terms as 
Perl itself, either Perl version 5.8.8 or, at your option, any later version of Perl 5 you may 
have available.
