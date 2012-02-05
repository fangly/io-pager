package IO::Pager::Buffered;
our $VERSION = 0.16;

use strict;
use base qw( IO::Pager );
use SelectSaver;


sub new(;$) {  # [FH]
  return 0 unless (my($class, $tied_fh) = &IO::Pager::_init);
  tie *$tied_fh, $class, $tied_fh or die "Could not tie $$tied_fh\n";
}

#Punt to base, preserving FH ($_[0]) for pass by reference to gensym
sub open(;$) { # [FH]
  IO::Pager::open($_[0], 'IO::Pager::Buffered');
}


# Overload IO::Pager methods

sub PRINT {
  my ($self, @args) = @_;
  $self->{buffer} .= join($,||'', @args);
}


sub CLOSE {
  my ($self) = @_;
  # Print buffer and close using IO::Pager's methods
  $self->SUPER::PRINT($self->{buffer}) if exists $self->{buffer};
  $self->SUPER::CLOSE();
}


sub TELL {
  # Return the size of the buffer
  my ($self) = @_;
  use bytes;
  return exists($self->{buffer}) ? length($self->{buffer}) : 0;
}


sub flush(;*) {
  my ($self) = @_;
  if( exists $self->{buffer} ){
    my $saver = SelectSaver->new($self->{real_fh});
    local $|=1;
    ($_, $self->{buffer}) = ( $self->{buffer}, '');
    $self->SUPER::PRINT($_);
  }
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

Class-specific method specifics:

=head2 new( [FILEHANDLE] )

Instantiate a new IO::Pager to paginate FILEHANDLE if necessary.
I<Assign the return value to a scoped variable>. Output does not
occur until all references to this variable are destroyed eg;
upon leaving the current scope. See L</DESCRIPTION>.

=head2 tell( FILEHANDLE )

Returns the size of the buffer in bytes.

=head2 flush( FILEHANDLE )

Immediately flushes the contents of the buffer.

=head1 CAVEATS

If you mix buffered and unbuffered operations the output order is unspecified,
and will probably differ for a TTY vs. a file. See L<perlfunc>.

I<$,> is used see L<perlvar>.

=head1 SEE ALSO

L<IO::Pager>, L<IO::Pager::Unbuffered>, L<IO::Pager::Page>,

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
