use strict;
use Test;

plan tests => 3;

use Djet::Starter;
use Djet::I18N;

my $djet_root = './';

ok(my $lh = Djet::I18N->get_handle($djet_root, 'da'));
ok($lh->maketext("Company", ), "Firma");
ok($lh->maketext("Email Address", ), "Email");
