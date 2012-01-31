use ExtUtils::MakeMaker qw(prompt);
use Env qw(HARNESS_ACTIVE);
use Test::More;
BEGIN { use_ok('IO::Pager') };

SKIP: {
  skip "Can not run with Test::Harness. Run 'perl -Mblib t.pl' after 'make test'.", 1
    if $HARNESS_ACTIVE;
  skip "Layers requires 5.8.0 or better", 1 if $] < 5.008;

  {
    local $STDOUT = new IO::Pager *BOB, 'IO::Pager::Buffered', ':utf8';
    for (1..50) {
        printf BOB "%06i ATTN: Unicode<\x{17d}\x{13d}>\tExit your pager when done.\n", $_;
    }
    close BOB;
  }

  binmode(STDOUT, ":utf8");
  $A = prompt("\n\n1) The block of text was sent to a pager\n2) You saw 'Unicode<\x{17d}\x{13d}>'\n3) There were no warnings about wide-characters\nWere the criteria above satisfied? [Yn]");
  ok( ($A =~ /^y(?:es)?/i || $A eq ''), 'Binmode layer selection');
}

done_testing;
