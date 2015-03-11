
CREATE or REPLACE FUNCTION json_string(data json, key text) RETURNS TEXT AS $$

use strict;
use warnings;
use JSON;

my ($data, $key) = @_;
my $json = JSON->new;
my $elm = $json->decode($data);

for my $part (split '.', $key) {
	$elm = $elm->{$part} if defined $elm;
}

return $elm;

$$ LANGUAGE plperlu IMMUTABLE STRICT;

CREATE or REPLACE FUNCTION json_int(data json, key text) RETURNS INT AS $$

use strict;
use warnings;
use JSON;

my ($data, $key) = @_;
my $json = JSON->new;
my $elm = $json->decode($data);

for my $part (split '.', $key) {
	$elm = $elm->{$part} if defined $elm;
}

return $elm =~ /^\d+$/ ? $elm : undef;

$$ LANGUAGE plperlu IMMUTABLE STRICT;

CREATE or REPLACE FUNCTION json_int_array(data json, key text) RETURNS INT[] AS $$

use strict;
use warnings;
use JSON;

my ($data, $key) = @_;
my $json = JSON->new;
my $elm = $json->decode($data);

for my $part (split '.', $key) {
	$elm = $elm->{$part} if defined $elm;
}

return ref $elm eq 'ARRAY' ? $elm : [$elm];

$$ LANGUAGE plperlu IMMUTABLE STRICT;

CREATE or REPLACE FUNCTION json_float(data json, key text) RETURNS DOUBLE PRECISION AS $$

use strict;
use warnings;
use JSON;

my ($data, $key) = @_;
my $json = JSON->new;
my $elm = $json->decode($data);

for my $part (split '.', $key) {
	$elm = $elm->{$part} if defined $elm;
}

return $elm =~ /^-?\d+\.?\d*$/ ? $elm : undef;

$$ LANGUAGE plperlu IMMUTABLE STRICT;


CREATE or REPLACE FUNCTION json_bool(data json, key text) RETURNS BOOLEAN AS $$

use strict;
use warnings;
use JSON;

my ($data, $key) = @_;
my $json = JSON->new;
my $elm = $json->decode($data);

for my $part (split '.', $key) {
	$elm = $elm->{$part} if defined $elm;
}

return $elm =~ /^(:?true|false)$/ ? $elm : undef;

$$ LANGUAGE plperlu IMMUTABLE STRICT;


CREATE or REPLACE FUNCTION json_date(data json, key text) RETURNS TIMESTAMP AS $$

use strict;
use warnings;
use JSON;
use Time::Local;

my ($data, $key) = @_;
my $json = JSON->new;
my $elm = $json->decode($data);

for my $part (split '.', $key) {
	$elm = $elm->{$part} if defined $elm;
}

$elm =~ s/\s+$//;
$elm =~ s/^\s*//;
my ($year, $month, $day) = unpack "A4 A2 A2", $elm;
eval{ 
    timelocal(0,0,0,$day, $month-1, $year);
};

return !$@ ? $elm : undef;

$$ LANGUAGE plperlu IMMUTABLE STRICT;

