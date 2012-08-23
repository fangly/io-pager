use strict;
use warnings;
use File::Temp;
use Test::More;
use t::TestUtils;

use 5.6.0;
use utf8;

use IO::Pager;

my $fileno = fileno(STDOUT);
{
  binmode(*STDOUT, ':encoding(UTF-8)');
  my $pager = IO::Pager->new(*STDOUT);
  $pager->say('Bonzai Bjørn');
  $pager->say("$/End of text, try pressing 'Q' to exit.");
  $pager->close();
}

#Reinstate some order
CORE::open(*BOB, ">&=$fileno");
binmode(*BOB, ':encoding(UTF-8)');
select(BOB);

my $A = prompt "\nDid you see 'Bonzai Bjørn' in your pager? Note the crossed o in the second word [Yn]";
ok is_yes($A), 'layer preservation';

done_testing;
