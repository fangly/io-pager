# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl 2.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use ExtUtils::MakeMaker qw(prompt);
use Env qw(PAGER HARNESS_ACTIVE);
use Test::More tests => 2;
BEGIN {
      diag qq(\nYour current \$PAGER: ").($PAGER||'').qq("\n);
      use_ok('IO::Pager');
};

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

diag qq(\nYour IO::Pager \$PAGER: ").($PAGER||'').qq("\n);
select(STDERR);

SKIP: {
  skip("Can not run with Test::Harness. Run 'perl -Mblib t.pl' after 'make test'.", 1)
    if $HARNESS_ACTIVE;

  my $A = prompt("\n\nIs this reasonable? [Yn]");
  ok( ($A =~ /^y(?:es)?/i || $A eq ''), 'Found a pager fine');
}
