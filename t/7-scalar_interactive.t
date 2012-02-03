use strict;
use warnings;
use Test::More;
use t::TestUtils;

# Test unbuffered paging

SKIP: {
  skip_interactive();
  
  require IO::Pager;


  {
    use Symbol;
    my $BOB =Symbol::gensym();
    local $STDOUT = IO::Pager::open($BOB, 'IO::Pager::Buffered');

    warn stat($BOB);

    isa_ok $STDOUT, 'IO::Pager::Buffered';
    isa_ok $STDOUT, 'Tie::Handle';

    eval {
      my $i = 0;
      for (1..50) {
        printf($BOB "%06i Printing text in a pager. Exit at any time by pressing 'Q'.\n", $_);
      }
    };
    close($BOB);
  }

  my $A = prompt "\nWas the text displayed in a pager? [Yn]";
  ok is_yes($A), 'Buffered scalar filehandle';
}

done_testing;
