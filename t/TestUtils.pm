package t::TestUtils;

use strict;
use warnings;
use Test::More;

use Env qw(PAGER HARNESS_ACTIVE);

use vars qw{@ISA @EXPORT};
BEGIN {
   @ISA     = 'Exporter';
   @EXPORT  = qw{
      skip_interactive
      skip_old_perl
      is_yes
   };
}

sub skip_interactive {
  skip "Run 'perl -Mblib t.pl' to perform interactive tests.", 1 if $HARNESS_ACTIVE;
}

sub skip_old_perl {
  skip "Layers requires Perl 5.8.0 or better.", 1 if $] < 5.008;
}

sub is_yes {
  my ($val) = @_;
  return ($val =~ /^y(?:es)?/i || $val eq '');
}

1;
