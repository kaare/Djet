#!/usr/bin/env perl

use 5.010;
use strict;
use warnings;

use Test::More;

my $db_name = '__jet_test__';

qx{dropdb -e $db_name} || BAIL_OUT(q{Couldn't drop test database.});
qx{createdb -e $db_name} || BAIL_OUT(q{Couldn't create test database. No PostgreSQL?});

ok(qx{psql $db_name -f sql/$_.sql}, "Create $_ Jet tables") for qw/jet basic user/;

ok(qx{psql $db_name -f t/sql/$_.sql}, "Create $_ Jet test tables") for qw/photo data/;

done_testing();
