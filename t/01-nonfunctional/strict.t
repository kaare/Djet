use strict;
use warnings;

use Test::Strict;

my $orig = \&Test::Strict::modules_enabling_strict;

no warnings 'redefine';

*Test::Strict::modules_enabling_strict = sub {
	return &$orig, 'MooseX::MethodAttributes::Role';
};

all_perl_files_ok( qw/bin lib t/);
