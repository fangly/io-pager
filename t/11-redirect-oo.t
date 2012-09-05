use strict;
use warnings;
use File::Temp;
use Test::More;
use t::TestUtils;

#Disable warnings for awkard test file mechanism required by Windows
my(undef, $tempname) = do{ $^W=0; File::Temp::tempfile(OPEN=>0)};
END{ close(TMP); unlink $tempname or die "Could not unlink '$tempname': $!" }

#Print the heredoc in 11-redirect.pl to temp file via redirection
system qq($^X t/11-redirect-oo.pl >$tempname);

open(TMP, $tempname) or die "Could not open tmpfile: $!\n";
my $slurp = do{ undef $/; <TMP> };

our $txt; require 't/08-redirect.pl';
ok($txt eq $slurp, 'Redirection with OO');

done_testing;
