package Jet::JSON;

use 5.010;
use strict;
use warnings;

use base 'JSON::XS';

=head1 NAME

Jet::JSON - (De)Serialize data

=head1 DESCRIPTION

Also serializes regexes

=cut

sub new {
	my $class = shift;
	my $self = $class->SUPER::new(@_);
	return $self->
		convert_blessed->
		filter_json_single_key_object(__regexp__ => \&regexp_load);
}

sub Regexp::TO_JSON {
	my $self = shift;
	return {__regexp__ => "$self"};
}

# NB! Deserialisation code stolen from YAML

use constant _QR_TYPES => {
    '' => sub { qr{$_[0]} },
    x => sub { qr{$_[0]}x },
    i => sub { qr{$_[0]}i },
    s => sub { qr{$_[0]}s },
    m => sub { qr{$_[0]}m },
    ix => sub { qr{$_[0]}ix },
    sx => sub { qr{$_[0]}sx },
    mx => sub { qr{$_[0]}mx },
    si => sub { qr{$_[0]}si },
    mi => sub { qr{$_[0]}mi },
    ms => sub { qr{$_[0]}sm },
    six => sub { qr{$_[0]}six },
    mix => sub { qr{$_[0]}mix },
    msx => sub { qr{$_[0]}msx },
    msi => sub { qr{$_[0]}msi },
    msix => sub { qr{$_[0]}msix },
};
 
sub regexp_load {
    my $node = shift;
    return qr{$node} unless $node =~ /^\(\?([\^\-xism]*):(.*)\)\z/s;
    my ($flags, $re) = ($1, $2);
    $flags =~ s/-.*//;
    $flags =~ s/^\^//;
    my $sub = _QR_TYPES->{$flags} || sub { qr{$_[0]} };
    my $qr = &$sub($re);
    return $qr;
}
 
1;
__END__

=head1 AUTHOR

Kaare Rasmussen, <kaare at cpan dot com>

=head1 BUGS 

Please report any bugs or feature requests to my email address listed above.

=head1 COPYRIGHT & LICENSE 

Copyright 2012 Kaare Rasmussen, all rights reserved.

This library is free software; you can redistribute it and/or modify it under the same terms as 
Perl itself, either Perl version 5.8.8 or, at your option, any later version of Perl 5 you may 
have available.
