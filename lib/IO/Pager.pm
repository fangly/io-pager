package IO::Pager;

use 5.008; #At least, for decent perlio, and other modernisms
use strict;
use base qw( Tie::Handle );
use Env qw( PAGER );
use File::Spec;
use Symbol;

our $VERSION = 0.16;


sub find_pager {
  # Return the name (or path) of a pager that IO::Pager can use
  my $io_pager;

  # Use File::Which if available (strongly recommended)
  my $which = eval { require File::Which };

  # Look for pager in PAGER first
  if ($PAGER) {
    # Strip arguments e.g. 'less --quiet'
    my ($pager, @options) = (split ' ', $PAGER);
    $pager = _check_pagers([$pager], $which);
    $io_pager = join ' ', ($pager, @options) if defined $pager;
  }

  # Then search pager amongst usual suspects
  if (not defined $io_pager) {
    my @pagers = ('/usr/local/bin/less', '/usr/bin/less', '/usr/bin/more');
    $io_pager = _check_pagers(\@pagers, $which) 
  }

  # Then try for common pagers in more exotic places
  if ( (not defined $io_pager) && $which ) {
    my @pagers = ['less', 'most', 'w3m', 'more'];
    $io_pager = _check_pagers(\@pagers, $which );
  }

  # If all else fails, default to more
  $io_pager ||= 'more';

  return $io_pager;
}


sub _check_pagers {
  my ($pagers, $which) = @_;
  # Return the first pager in the list that is usable. For each given pager, 
  # given a pager name, try to finds its full path with File::Which if possible.
  # Given a pager path, verify that it exists.
  my $io_pager = undef;
  for my $pager (@$pagers) {
    # Get full path
    my $loc;
    if ( $which && (not File::Spec->file_name_is_absolute($pager)) ) {
      $loc = File::Which::which($pager);
    } else {
      $loc = $pager;
    }
    # Test that full path is valid (some platforms don't do -x so we use -e)
    if ( defined($loc) && (-e $loc) ) {
      $io_pager = $loc;
      last;
    }
  }
  return $io_pager;
}


BEGIN {
  # Set the PAGER environment variable to something reasonable
  $PAGER = find_pager();
}


sub new(;$$) {
  my ($class, $out_fh, $subclass) = @_;
  IO::Pager::open($out_fh, $subclass);
}


sub open(;$$) {
  #Assign by reference if empty scalar given as filehandle
  $_[0] = gensym() if exists($_[0]) && !defined($_[0]);
  warn($_[0]);

  my ($out_fh, $subclass) = @_;
  $subclass ||= 'IO::Pager::Unbuffered';
  $subclass =~ s/^(?!IO::Pager::)/IO::Pager::/;
  eval "require $subclass" or die "Could not load $subclass: $@\n";
  $subclass->new($out_fh, $subclass);
}

#sub OPEN{
#  
#}

# Methods required for implementing a tied filehandle class

sub TIEHANDLE {
  my ($class, $out_fh) = @_;
  unless ( $PAGER ){
    die "The PAGER environment variable is not defined, you may need to set it manually.";
  }
  my($tied_fh, $child);
  unless ( $child = CORE::open($tied_fh, "| $PAGER") ){
    $! = "Could not pipe to PAGER ('$PAGER'): $!\n";
    return 0;
  }
  return bless {
                'out_fh'  => $out_fh,
                'tied_fh' => $tied_fh,
                'child'   => $child
               }, $class;
}


sub BINMODE {
  my ($self, $layer) = @_;
  CORE::binmode($self->{tied_fh}, $layer||':raw');
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


sub UNTIE {
  my ($self) = @_;
  CORE::close($self->{tied_fh});
}


sub CLOSE {
  my ($self) = @_;
  untie *{$self->{out_fh}};
}


sub TELL {
  #Buffered classes provide their own, and others may use this in another way
  return undef;
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
    #local $retval =     IO::Pager::open *STDOUT; # Defaults to 'Unbuffered'
    local  $retval = new IO::Pager       *STDOUT, 'Buffered';
    print <<"  HEREDOC" ;
    ...
    A bunch of text later
    HEREDOC
  }

=head1 DESCRIPTION

IO::Pager can be used to locate an available pager and set the I<PAGER>
environment variable (see L</NOTES>). It is also a factory for creating
I/O objects such as L<IO::Pager::Buffered> and L<IO::Pager::Unbuffered>.

IO::Pager subclasses are designed to programmatically decide whether
or not to pipe a filehandle's output to a program specified in I<PAGER>.
Subclasses may implement only the IO handle methods desired and inherit
the following from IO::Pager:

=over

=item BINMODE

Used to set the I/O layer a.ka. discipline of a filehandle,
such as C<':utf8'> for UTF-8 encoding.

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

The object will be of type SUBCLASS (L<IO::Pager::Unbuffered> by default). See
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

If File::Which is available, use the first pager possible amongst C<less>,
C<most>, C<w3m> and L<more>.

=item 4. more

Set I<PAGER> to C<more>, and cross our fingers.

=back

Steps 1, 3 and 4 rely upon the I<PATH> environment variable.

=head1 SEE ALSO

L<IO::Pager::Buffered>, L<IO::Pager::Unbuffered>, L<IO::Pager::Page>,

L<IO::Page>, L<Meta::Tool::Less>

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
