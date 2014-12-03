use strict;
use Test;

plan tests => 3;

use Djet::I18N;

ok(my $lh = Djet::I18N->get_handle('da'));
ok($lh->maketext("Company", ), "Firma");
ok($lh->maketext("Email Address", ), "Mailadresse");
