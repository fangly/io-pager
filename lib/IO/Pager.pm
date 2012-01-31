package IO::Pager;

use 5;
use strict;
use Env qw( PAGER );
use File::Spec;
use IO::WrapTie;

our $VERSION = 0.10;


BEGIN {
  # Find a pager to use and set the PAGER environment variable
  my $which = eval { require File::Which };
  my @pagers;
  push @pagers, $PAGER if $PAGER;
  push @pagers, '/usr/local/bin/less', '/usr/bin/less', '/usr/bin/more';
  push @pagers, 'less', 'more' if $which;
  LOOP: for my $pager (@pagers) {
    # Find the full path of the pager if needed
    my @locs;
    if ( $which && (not File::Spec->file_name_is_absolute($pager)) ) {
      @locs = File::Which::where($pager);
      next if scalar @locs == 0;
    } else {
      @locs = ($pager);
    }
    # Some platforms don't do -x so we use -e
    for my $loc (@locs) {
      if (-e $loc) {
        # Found a suitable pager
        $PAGER = $loc;
        last LOOP;
      }
    }
  }
  # If all else failed, default to more
  $PAGER ||= 'more';
}

sub new(;$$) {
  my ($class, $out_fh, $subclass) = @_;
  IO::Pager::open($out_fh, $subclass);
}


sub open(;$$) {
  my ($out_fh, $subclass) = @_;
  $subclass ||= 'IO::Pager::Unbuffered';
  $subclass =~ s/^(?!IO::Pager::)/IO::Pager::/;
  eval "require $subclass" or die "Could not load $subclass: $@\n";
  # Undefined subroutine &IO::Pager::Unbuffered::TIEHANDLE
  #my $FH = wraptie($subclass, $_[0]);
  $subclass->new($out_fh, $subclass);
}

1;

__END__

=head1 NAME

IO::Pager - Select a pager and pipe text to it if destination is a TTY

=head1 SYNOPSIS

  # Select an appropriate pager and set the PAGER environment variable
  use IO::Pager;

  # Optionally, pipe output to it
  {
    #local $retval =     IO::Pager::open *STDOUT; #
    local  $retval = new IO::Pager       *STDOUT, 'Buffered';
    print <<"  HEREDOC" ;
    ...
    A bunch of text later
    HEREDOC
  }

=head1 DESCRIPTION

IO::Pager is a lightweight module to locate an available pager and set
the I<PAGER> environment variable (see L</NOTES>). It is also a factory for
creating objects such as L<IO::Pager::Buffered> and L<IO::Pager::Unbuffered>.

IO::Pager subclasses are designed to programmatically decide whether
or not to pipe a filehandle's output to a program specified in I<PAGER>.
Subclasses are only required to support these filehandle methods:

=over

=item BINMODE

Supports binmode() of the filehandle for I/O layer selection like UTF-8 encoding.

=item CLOSE

Supports close() of the filehandle.

=item PRINT

Supports print() to the filehandle.

=item PRINTF

Supports printf() to the filehandle.

=item WRITE

Supports syswrite() to the filehandle.

=back

For anything else, YMMV.

=head2 new( [FILEHANDLE], [SUBCLASS] )

Instantiate a new IO::Pager to paginate FILEHANDLE if necessary.
I<Assign the return value to a scoped variable>.

The object will be of type SUBCLASS (L<IO::Pager::Unbuffered by default). See
the appropriate subclass for details.

=over

=item FILEHANDLE

Defaults to currently select()-ed FILEHANDLE.

=item EXPR

An expression which evaluates to the subclass of object to create.

Defaults to L<IO::Pager::Unbuffered>.

=back

=head2 open( [FILEHANDLE], [EXPR] )

An alias for new.

=head2 close( FILEHANDLE )

Explicitly close the filehandle, this stops any redirection of output
on FILEHANDLE that may have been warranted. Normally you'd just wait
for the object to pass out of scope.

I<This does not default to the current filehandle>.

See the appropriate subclass for implementation specific details.

=head1 ENVIRONMENT

=over

=item PAGER

The location of the default pager.

=item PATH

If PAGER does not specify an absolute path for the binary PATH may be used.

See L</NOTES> for more information.

=back

=head1 FILES

IO::Pager may fall back to these binaries in order if I<PAGER> is not
executable.

=over

=item /usr/local/bin/less

=item /usr/bin/less

=item /usr/bin/more

=back

See L</NOTES> for more information.

=head1 NOTES

The algorithm for determining which pager to use is as follows:

=over

=item 1. Defer to I<PAGER>

If the I<PAGER> environment variable is set, use the pagger it identifies,
unless this pager is not available.

=item 2. Usual suspects

Try the standard, hardcoded paths in L</FILES>.

=item 3. File::Which

If File::Which is available check if C<less> or L<more> can be used.

=item 4. more

Set I<PAGER> to C<more>

=back

Steps 1, 3 and 4 rely upon the $PATH environment variable.

=head1 SEE ALSO

L<IO::Pager::Buffered>, L<IO::Pager::Unbuffered>, L<IO::Pager::Page>

L<IO::Page>, L<Meta::Tool::Less>

=head1 AUTHOR

Jerrad Pierce <jpierce@cpan.org>

This module inspired by Monte Mitzelfelt's IO::Page 0.02

=head1 LICENSE

=over

=item * Thou shalt not claim ownership of unmodified materials.

=item * Thou shalt not claim whole ownership of modified materials.

=item * Thou shalt grant the indemnity of the provider of materials.

=item * Thou shalt use and dispense freely without other restrictions.

=back

=cut
