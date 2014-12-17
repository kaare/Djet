#!/usr/bin/env perl

use 5.010;
use strict;
use warnings;

use Test::More;

use lib 't/lib';
use Test;

my $db_name = Test::db_name;

ok(qx{psql $db_name -c "DROP role djet_user"}, "Drop Djet test user");

done_testing();
