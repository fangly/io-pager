# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl 1.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use ExtUtils::MakeMaker qw(prompt);
use Test::More tests => 2;
BEGIN {
      diag qq(\nYour current \$ENV{PAGER} = "$ENV{PAGER}"\n);
      use_ok('IO::Pager') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

diag qq(\nYour IO::Pager \$ENV{PAGER} = "$ENV{PAGER}"\n);
select(STDERR);
my $A = prompt("\n\nIs this reasonable? [Yn]");
ok( ($A =~ /^y(?:es)?/i || $A eq ''), 'Found a pager fine');
