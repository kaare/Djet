#!/usr/bin/env perl

use 5.010;
use strict;
use warnings;

use Test::More;

use lib 't/lib';
use Test;

my $db_name = Test::db_name;

qx{dropdb -e $db_name} || BAIL_OUT(q{Couldn't drop test database.});
qx{createdb -e $db_name} || BAIL_OUT(q{Couldn't create test database. No PostgreSQL?});
# ok(qx{psql $db_name -f sql/$_.sql}, "Create $_ Djet tables") for qw/djet basic user/;
ok(qx{psql $db_name -f sql/$_.sql}, "Create $_ Djet tables") for qw/djet/;

# ok(qx{psql $db_name -f t/sql/$_.sql}, "Create $_ Djet test tables") for qw/photo data/;
ok(qx{psql $db_name -f sql/$_.sql}, "Create $_ Djet test tables") for qw/basic/;

ok(qx{psql $db_name -c "CREATE role djet_user WITH LOGIN SUPERUSER PASSWORD 'djet_user'"}, "Create Djet test user");

done_testing();
