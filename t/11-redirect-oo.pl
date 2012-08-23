use blib;
use IO::Pager;
use Test::More;

my $FH = new IO::Pager;

if(! @ARGV){
    our $txt; require 't/08-redirect.pl';
    use Data::Dumper 'Dumper'; print Dumper $FH;
    $FH->print($txt);
}
else{
    isa_ok($FH, 'IO::Pager::less');
    isa_ok($FH, 'IO::Handle');
    done_testing;
}
