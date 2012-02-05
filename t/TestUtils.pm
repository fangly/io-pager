package t::TestUtils;

use strict;
use warnings;
use Config;
use Test::More;
use Env qw( HARNESS_ACTIVE );
use ExtUtils::MakeMaker qw( prompt );

use base qw( Exporter );
our @EXPORT;
BEGIN {
   @EXPORT  = qw{
      skip_interactive
      skip_old_perl
      skip_no_file_which
      is_yes
      perl_exe
      perl_path
      prompt
   };
}

sub skip_interactive {
  skip "Run 'perl -Mblib t.pl' to perform interactive tests.", 1 if $HARNESS_ACTIVE;
}

sub skip_old_perl {
  skip "Layers requires Perl 5.8.0 or better.", 1 if $] < 5.008;
}

sub skip_no_file_which {
  skip "This test requires File::Which.", 1 if not eval { require File::Which };
}

sub is_yes {
  my ($val) = @_;
  return ($val =~ /^y(?:es)?/i || $val eq '');
}

sub perl_exe {
  # Find the Perl executable name
  my $this_perl = $^X;
  $this_perl = (File::Spec->splitpath( $this_perl ))[-1];
  return $this_perl;
}

sub perl_path {
  # Find the Perl full-path (taken from the perlvar documentation)
  my $this_perl = $^X;
  if ($^O ne 'VMS') {
    $this_perl .= $Config{_exe}
    unless $this_perl =~ m/$Config{_exe}$/i;
  }
  return $this_perl;
}

1;
