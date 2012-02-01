package IO::Pager::Buffered;

use 5;
use strict;
use IO::Pager::TiedStream;

our $VERSION = 0.10;


sub new(;$) {
  my ($class, $out_fh) = @_;
  no strict 'refs';
  $out_fh ||= *{select()};
  # STDOUT & STDERR are separately bound to tty
  if ( defined( my $FHn = fileno($out_fh) ) ) {
    if ( $FHn == fileno(STDOUT) ) {
      return 0 unless -t $out_fh;
    }
    if ( $FHn == fileno(STDERR) ) {
      return 0 unless -t $out_fh;
    }
  }
  # This allows us to have multiple pseudo-STDOUT
  return 0 unless -t STDOUT;
  my $buffered = 1;
  tie *$out_fh, 'IO::Pager::TiedStream', $out_fh, $buffered
    or die "Could not tie $$out_fh\n";
}

sub open(;$) {
  my ($out_fh) = @_;
  new IO::Pager::Buffered $out_fh;
}

1;

__END__

=head1 NAME

IO::Pager::Buffered - Pipe deferred output to a pager if destination is to a TTY

=head1 SYNOPSIS

  use IO::Pager::Buffered;
  {
    #local $STDOUT =     IO::Pager::Buffered::open *STDOUT;
    local  $STDOUT = new IO::Pager::Buffered       *STDOUT;
    print <<"  HEREDOC" ;
    ...
    A bunch of text later
    HEREDOC
  }

=head1 DESCRIPTION

IO::Pager is designed to programmatically decide whether or not to point
the STDOUT file handle into a pipe to program specified in the I<PAGER>
environment variable or one of a standard list of pagers.

This subclass buffers all output for display upon exiting the current scope.
If this is not what you want look at another subclass such as
L<IO::Pager::Unbuffered>. While probably not common, this may be useful in
some cases,such as buffering all output to STDOUT while the process occurs,
showing only warnings on STDERR, then displaying the output to STDOUT after.
Or alternately letting output to STDOUT slide by and defer warnings for later
perusal.

=head2 new( [FILEHANDLE] )

Instantiate a new IO::Pager to paginate FILEHANDLE if necessary.
I<Assign the return value to a scoped variable>. Output does not
occur until all references to this variable are destroyed eg;
upon leaving the current scope. See L</DESCRIPTION>.

=over

=item FILEHANDLE

Defaults to currently select()-ed FILEHANDLE.

=back

=head2 open( [FILEHANDLE] )

An alias for new.

=head2 close( FILEHANDLE )

Explicitly close the filehandle, this stops collecting and displays the
output, executing a pager if necessary. Normally you would just wait for
the object to pass out of scope.

I<This does not default to the current filehandle>.

=head1 CAVEATS

If you mix buffered and unbuffered operations the output order is unspecified,
and will probably differ for a TTY vs. a file. See L<perlfunc>.

I<$,> is used see L<perlvar>.

=head1 SEE ALSO

L<IO::Pager>, L<IO::Pager::Unbuffered>, L<IO::Pager::Page>,
L<IO::Pager::TiedStream>

=head1 AUTHOR

Jerrad Pierce <jpierce@cpan.org>

Florent Angly <florent.angly@gmail.com>

This module was inspired by Monte Mitzelfelt's IO::Page 0.02

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2003-2012 Jerrad Pierce

=over

=item * Thou shalt not claim ownership of unmodified materials.

=item * Thou shalt not claim whole ownership of modified materials.

=item * Thou shalt grant the indemnity of the provider of materials.

=item * Thou shalt use and dispense freely without other restrictions.

=back

Or, if you prefer:

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.0 or,
at your option, any later version of Perl 5 you may have available.

=cut
