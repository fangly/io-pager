use strict;
use warnings;
use Test::More;
use t::TestUtils;

# Test OO interface

SKIP: {
  skip_interactive();

  require IO::Pager;
  {
    my $BOB = new IO::Pager undef, 'IO::Pager::Buffered' or die "Failed to create PAGER FH $!";

    isa_ok $BOB, 'IO::Pager::Buffered';

    $BOB->print("OO filehandle methods\n");
    $BOB->print("\nEnd of text, try pressing 'Q' to exit.\n");
    $BOB->close();
  };

  my $A1 = prompt "\nDid you see 'OO filehandle methods' in your pager? [Yn]";
  ok is_yes($A1), 'OO, factory instantiation';

  require IO::Pager::Unbuffered;

  {
    my $BOB = new IO::Pager::Unbuffered or die "Failed to create PAGER FH $!";

    isa_ok $BOB, 'IO::Pager::Unbuffered';

    $BOB->print("OO filehandle methods\n");
    $BOB->print("\nEnd of text, try pressing 'Q' to exit.\n");
    $BOB->close();
  };

  my $A2 = prompt "\nDid you see 'OO filehandle methods' in your pager? [Yn]";
  ok is_yes($A2), 'OO, subclass instantiation';
}

done_testing;
