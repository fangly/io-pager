use strict;
use warnings;
use Test::More;
use t::TestUtils;

# Test paging binary content

SKIP: {
  skip_interactive();
  skip_old_perl();

  require IO::Pager;

  my $warnings;
  eval {
    # Promote warnings to errors so we can catch them
    $SIG{__WARN__} = sub { $warnings .= shift };

    # Stream unicode in a pager
    local $STDOUT = new IO::Pager *BOB, 'IO::Pager::Buffered';
    binmode BOB, ":utf8";
    for (1..30) {
      printf BOB "%06i ATTN: Unicode<\x{17d}\x{13d}>\n", $_;
    }
    printf BOB "End of text. Exit by pressing 'Q'.\n", $_;
    close BOB;
  };

  is $warnings, undef, 'No wide character warnings';

  binmode STDOUT, ":utf8";
  my $A = prompt "\nWas text containing 'Unicode<\x{17d}\x{13d}>' displayed in a pager? [Yn]";
  ok is_yes($A), 'Binmode layer selection';
}

done_testing;
