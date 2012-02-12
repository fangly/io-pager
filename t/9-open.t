use strict;
use warnings;
use Test::More;
use t::TestUtils;

use IO::Pager;

undef $ENV{PAGER};
eval{ my $token = new IO::Pager };
like($@, qr/The PAGER environment variable is not defined/, 'PAGER undefined since find_pager()');

$ENV{PAGER} = '/dev/null';
eval{ my $token = new IO::Pager or die $!};
like($@, qr/Could not pipe to PAGER/, 'Could not create pipe');

done_testing;

