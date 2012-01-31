package IO::Pager::Unbuffered;

use 5;
use strict;
use Env qw( PAGER );
use Tie::Handle;
use base qw( Tie::Handle );

our $VERSION = 0.10;


sub new(;$) {
  my ($class, $out_fh) = @_;
  no strict 'refs';
  $out_fh ||= *{select()};
  # STDOUT & STDERR are separately bound to tty
  if( defined( my $FHn = fileno($out_fh) ) ){
    if( $FHn == fileno(STDOUT) ){
      return 0 unless -t $out_fh;
    }
    if( $FHn == fileno(STDERR) ){
      return 0 unless -t $out_fh;
    }
  }
  # This allows us to have multiple pseudo-STDOUT
  return 0 unless -t STDOUT;
  tie *$out_fh, $class, $out_fh or die "Could not tie $$out_fh\n";
}

sub open(;$) {
  my ($out_fh) = @_;
  new IO::Pager::Unbuffered $out_fh;
}

sub TIEHANDLE {
  my ($class, $out_fh) = @_;
  if (not $PAGER) {
    my $class = __PACKAGE__;
    die "The PAGER environment variable is not defined. Set it manually ".
      "or do 'use IO::Pager;' before 'use $class;' for it to be automagically ".
      "populated.\n";
  }
  my $tied_fh;
  unless (CORE::open($tied_fh, "| $PAGER")) {
    $! = "Could not pipe to PAGER ('$PAGER'): $!\n";
    return 0;
  }
  my $self = bless {}, $class;
  $self->{out_fh}  = $out_fh;
  $self->{tied_fh} = $tied_fh;
  $self->{closed}  = 0;
  return $self;
}

sub BINMODE {
  my ($self, @args) = @_;
  binmode($self->{tied_fh}, @args);
}

sub PRINT {
  my ($self, @args) = @_;
  CORE::print {$self->{tied_fh}} @args or die "Could not print on tied filehandle\n$!\n";
}

sub PRINTF {
  my ($self, $format, @args) = @_;
  PRINT $self, sprintf($format, @args);
}

sub WRITE {
  my ($self, $scalar, $length, $offset) = @_;
  PRINT $self, substr($scalar, $offset||0, $length);
}

sub CLOSE {
  my ($self) = @_;
  # return if $self->{closed}++; ### ?
  untie *{$self->{out_fh}};
  close $self->{tied_fh};
}

1;

__END__

=head1 NAME

IO::Pager::Unbuffered - Pipe output to a pager if destination is to a TTY

=head1 SYNOPSIS

  use IO::Pager::Unbuffered;
  {
    #local $STDOUT =     IO::Pager::Unbuffered::open *STDOUT;
    local  $STDOUT = new IO::Pager::Unbuffered       *STDOUT;
    print <<"  HEREDOC" ;
    ...
    A bunch of text later
    HEREDOC
  }

=head1 DESCRIPTION

IO::Pager is designed to programmatically decide whether or not to point
the STDOUT file handle into a pipe to program specified in the I<PAGER>
environment variable or one of a standard list of pagers.

=head2 new( [FILEHANDLE] )

Instantiate a new IO::Pager to paginate FILEHANDLE if necessary.
I<Assign the return value to a scoped variable>.

=over

=item FILEHANDLE

Defaults to currently select()-ed FILEHANDLE.

=back

=head2 open( [FILEHANDLE] )

An alias for new.

=head2 close( FILEHANDLE )

Explicitly close the filehandle, if a pager was deemed necessary this
will kill it. Normally you would just wait for the user to exit the pager
and the object to pass out of scope.

I<This does not default to the current filehandle>.

=head1 CAVEATS

You probably want to do something with SIGPIPE eg;

  eval {
    $SIG{PIPE} = sub { die };
    local $STDOUT = IO::Pager::open(*STDOUT);

    while (1) {
      # Do something
    }
  }

  # Do something else

=head1 SEE ALSO

L<IO::Pager>, L<IO::Pager::Buffered>, L<IO::Pager::Page>

=head1 AUTHOR

Jerrad Pierce <jpierce@cpan.org>

This module inspired by Monte Mitzelfelt's IO::Page 0.02

Significant proddage provided by Tye McQueen.

=head1 LICENSE

=over

=item * Thou shalt not claim ownership of unmodified materials.

=item * Thou shalt not claim whole ownership of modified materials.

=item * Thou shalt grant the indemnity of the provider of materials.

=item * Thou shalt use and dispense freely without other restrictions.

=back

=cut
