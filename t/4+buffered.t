# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl 4.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use ExtUtils::MakeMaker qw(prompt);
use Env qw(HARNESS_ACTIVE);
use Test::More tests => 3;
BEGIN { use_ok('IO::Pager') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.


SKIP: {
  skip("Can not run with Test::Harness. Run 'perl -Mblib t.pl' after 'make test'.", 2)
    if $HARNESS_ACTIVE;
  
  diag(<<EOF

Here's some text. Reading is fun.  ABCDEFGHIJKLMNOPQRSTUVWXYZ
You should not see this text from within a pager.

EOF
  );

  select(STDERR);
  my $A = prompt("\n\nWas that sent directly to your TTY? [Yn]");
  ok( ($A =~ /^y(?:es)?/i || $A eq ''), 'diag works');
  
  {
    local $STDOUT = new IO::Pager *BOB, 'IO::Pager::Buffered';
    for (1..50) {
      printf BOB "%06i Exit the pager when you have seen enough: press 'Q'.\n", $_;
    }
    close BOB;
  }

  $A = prompt("\n\nWas that sent to a pager? [Yn]");
  ok( ($A =~ /^y(?:es)?/i || $A eq ''), 'IO::Pager::Buffered works');
}
