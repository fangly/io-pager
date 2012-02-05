use strict;
use warnings;
use Test::More;
use t::TestUtils;
use Env qw( PAGER );

use IO::Pager;

my $pager;

$PAGER = undef;
$pager = IO::Pager::find_pager();
ok $pager, 'Undefined PAGER';

$PAGER = '';
$pager = IO::Pager::find_pager();
ok $pager, 'Blank PAGER';

$PAGER = 'asdfghjk666';
$pager = IO::Pager::find_pager();
isnt $pager, 'asdfghjk666', 'PAGER does not exist';

# Perl is sure to be present, but not a pager. Pretend that Perl is the pager.
$PAGER = perl_path();
$pager = IO::Pager::find_pager();
is $pager, perl_path(), 'PAGER referred by its full-path';

SKIP: {
  skip_no_file_which();

  $PAGER = perl_exe();
  $pager = IO::Pager::find_pager();
  like $pager, qr/perl/i, 'PAGER is referred by its executable name';
}

$PAGER = perl_path().' --quiet';
$pager = IO::Pager::find_pager();
is $pager, perl_path().' --quiet', 'PAGER with options';

done_testing;



