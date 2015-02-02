use utf8;
package Djet::Schema;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use Moose;
use MooseX::MarkAsMethods autoclean => 1;

use Text::CleanFragment;

extends 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces;


# Created by DBIx::Class::Schema::Loader v0.07040 @ 2014-12-03 20:17:47
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Bg4Uj9qvwklM5fJC6bErcQ

__PACKAGE__->meta->make_immutable(inline_constructor => 0);

# COPYRIGHT

__END__
