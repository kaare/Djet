package Djet::Trait::Field::File;

use Moose::Role;

=head1 NAME

MD::Trait::Field::Image - decorate the Image field

=cut

=head1 METHODS

=head2 unpack


=cut

sub unpack {
    my $self = shift;
    return $self->value;
}

=head2 path

Return the path information

=cut

sub path {
    my $self = shift;
    return unless $self->value;

    my ($x, $y) = @_;
    my $value = (split /\//, $self->value->{path}, 3)[2];
    my ($file, $ext) = split /\./,  $value;
    return "$file.$ext" unless $x && $y;

    my $new = $file . '_' . $x . 'x' . $y . '.' . $ext;
    return $new;
}

no Moose::Role;

1;
