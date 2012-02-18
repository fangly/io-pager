use strict;
use warnings;
use File::Spec;
use Test::More;
use t::TestUtils;
no warnings; $^W = 0; #Avoid: Can't exec "/dev/null": Permission denied

use IO::Pager;

undef $ENV{PAGER};
eval{ my $token = new IO::Pager };
like($@, qr/The PAGER environment variable is not defined/, 'PAGER undefined since find_pager()');

$ENV{PAGER} = File::Spec->devnull();
eval{ my $token = new IO::Pager or die $!};
like($@, qr/Could not pipe to PAGER/, 'Could not create pipe');

done_testing;

