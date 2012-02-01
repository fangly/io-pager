use strict;
use warnings;
use Test::More;
use t::TestUtils;
use Env qw( PAGER );

use IO::Pager;

my $pager;

$PAGER = undef;
warn "\nSetting PAGER to undef\n";
$pager = IO::Pager::_find_pager();
warn "PAGER is '$pager'\n";
ok $pager, 'Undefined PAGER';

$PAGER = '';
warn "\nSetting PAGER to '$PAGER'\n";
$pager = IO::Pager::_find_pager();
warn "PAGER is '$pager'\n";
ok $pager, 'Blank PAGER';

$PAGER = 'asdfghjk666';
warn "\nSetting PAGER to '$PAGER'\n";
$pager = IO::Pager::_find_pager();
warn "PAGER is '$pager'\n";
isnt $pager, 'asdfghjk666', 'PAGER does not exist';

# Perl is sure to be present, but not a pager. Pretend that Perl is the pager.
$PAGER = perl_path();
warn "\nSetting PAGER to '$PAGER'\n";
$pager = IO::Pager::_find_pager();
warn "PAGER is '$pager'\n";
is $pager, perl_path(), 'PAGER refered by its full-path';

$PAGER = perl_exe();
warn "\nSetting PAGER to '$PAGER'\n";
$pager = IO::Pager::_find_pager();
warn "PAGER is '$pager'\n";
like $pager, qr/perl/i, 'PAGER is refered by its executable name';

$PAGER = perl_path().' --quiet';
warn "\nSetting PAGER to '$PAGER'\n";
$pager = IO::Pager::_find_pager();
warn "PAGER is '$pager'\n";
is $pager, perl_path().' --quiet', 'PAGER with options';

done_testing;



