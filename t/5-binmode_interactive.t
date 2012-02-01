use strict;
use warnings;
use Test::More;
use t::TestUtils;
use ExtUtils::MakeMaker qw(prompt);

# Test paging binary content

SKIP: {
  skip_interactive();
  skip_old_perl();

  require IO::Pager;

  {
    local $STDOUT = new IO::Pager *BOB, 'IO::Pager::Buffered', ':utf8';
    for (1..50) {
      printf BOB "%06i ATTN: Unicode<\x{17d}\x{13d}>\n", $_;
    }
    printf BOB "End of text. Exit by pressing 'Q'.\n", $_;
    close BOB;
  }

  binmode STDOUT, ":utf8";
  my $A = prompt "\n".
                 "1) The block of text was sent to a pager\n".
                 "2) You saw 'Unicode<\x{17d}\x{13d}>'\n".
                 "3) There were no warnings about wide-characters\n".
                 "Were all criteria above satisfied? [Yn]";
  ok is_yes($A), 'Binmode layer selection';
}

done_testing;
