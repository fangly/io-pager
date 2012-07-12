use strict;
use warnings;
use File::Temp;
use Test::More;
use t::TestUtils;

my $temp = File::Temp->new();
my $tempname = $temp->filename();
$temp->unlink_on_destroy(1);

#Print the heredoc in 08-redirect.pl to temp file via redirection
system qq($^X -Mblib -MIO::Pager::Page -e 'require "t/08-redirect.pl"; print \$txt' >$tempname);

open(TMP, $tempname) or die "Could not open tmpfile: $!\n";
my $slurp = do{ undef $/; <TMP> };

our $txt; require 't/08-redirect.pl';
ok($txt eq $slurp, 'Redirection');

done_testing;
