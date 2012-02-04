use strict;
use warnings;
use Test::More;
use t::TestUtils;

# Test IPC

require IO::Pager;

{
  local $STDOUT = new IO::Pager *BOB;

  eval {
    my $i = 0;
#    until ( eof(BOB) ) {
    while( 1 ) {
      printf(BOB "%06i Please interrupt this pager, hit Ctrl-C\n", $i++);
      #kill(9, $STDOUT->{child}) if $i == 123;
    }
    ok $i==13, 'Killed';
  };
}


done_testing;
