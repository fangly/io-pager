use strict;
use warnings;
use Test::More;
use t::TestUtils;

# Test buffered paging

SKIP: {
  skip_interactive();

  require IO::Pager;
  
  diag "\n".
       "Reading is fun! Here is some text: ABCDEFGHIJKLMNOPQRSTUVWXYZ\n".
       "This text should be displayed directly on screen, not within a pager.\n".
       "\n";

  select STDERR;
  my $A = prompt "\nWas the text displayed directly on screen? [Yn]";
  ok is_yes($A), 'Diagnostic';
  
  {
    local $STDOUT = new IO::Pager *BOB, 'IO::Pager::Buffered';

    isa_ok $STDOUT, 'IO::Pager::Buffered';
    isa_ok $STDOUT, 'Tie::Handle';

    for (1..50) {
      printf BOB "%06i Printing text in a pager.\n", $_;
    }
    printf BOB "\nEnd of text, try pressing 'Q' to exit.\n", $_;
    close BOB;
  }

  $A = prompt "\nWas the text displayed in a pager? [Yn]";
  ok is_yes($A), 'Buffered glob filehandle';
}

done_testing;
