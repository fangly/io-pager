use strict;
use warnings;
use File::Temp;
use Test::More;
use t::TestUtils;

#Disable warnings for awkard test file mechanism required by Windows
my(undef, $tempname) = do{ $^W=0; File::Temp::tempfile(OPEN=>0)};
END{ close(TMP); unlink $tempname or die "Could not unlink '$tempname': $!" }

#Test the inehritance in 11-redirect.pl and save to temp file via redirection
system qq($^X t/11-redirect-oo.pl inherit >$tempname 2>&1);

my $slurp = do{ undef $/; <$temp> };
my $embeddedT = <<EOT;
ok 1 - The object isa IO::Pager::less
ok 2 - The object isa IO::Handle
1..2
EOT
ok($embeddedT eq $slurp, 'OO pagerless fallback type');


#XXX
$temp = File::Temp->new();
$tempname = $temp->filename();
$temp->unlink_on_destroy(1);

#Print the heredoc in 11-redirect.pl to temp file via redirection
system qq($^X -Mblib t/11-redirect-oo.pl >$tempname);
warn qq($^X -Mblib t/11-redirect-oo.pl >$tempname);

$slurp = do{ undef $/; <$temp> };
#XXX Perl on Windoze lamely appends an extra newline
#Experimentation with C<use open> layers failed to find a suitable remedy
chop($slurp) if $^O =~ /MSWin32/;

our $txt; require 't/08-redirect.pl';
ok($txt eq $slurp, 'Redirection with OO');


done_testing;
