package IO::Pager::TiedStream;

use 5;
use strict;
use Env qw( PAGER );
use base qw( Tie::Handle );

our $VERSION = 0.10;


sub TIEHANDLE {
  my ($class, $out_fh, $buffered) = @_;
  $buffered ||= 0;
  if (not $PAGER) {
    die "The PAGER environment variable is not defined. Set it manually ".
      "or do 'use IO::Pager;' for it to be automagically populated.\n";
  }
  my $tied_fh;
  unless (CORE::open($tied_fh, "| $PAGER")) {
    $! = "Could not pipe to PAGER ('$PAGER'): $!\n";
    return 0;
  }
  my $self = bless {}, $class;
  $self->{out_fh}  = $out_fh;
  $self->{tied_fh} = $tied_fh;
  $self->{buffer} = '' if $buffered;
  return $self;
}


sub BINMODE {
  my ($self, @args) = @_;
  binmode $self->{tied_fh}, @args;
}


sub PRINT {
  my ($self, @args) = @_;
  if (exists $self->{buffer}) {
    $self->{buffer} .= join($,||'', @args);
  } else {
    $self->_print(@args);
  }
}

sub _print {
  my ($self, @args) = @_;
  CORE::print {$self->{tied_fh}} @args or die "Could not print on tied filehandle\n$!\n";
}


sub PRINTF {
  my ($self, $format, @args) = @_;
  PRINT $self, sprintf($format, @args);
}


sub TELL {
  # Return how big the buffer is
  my ($self) = @_;
  return exists($self->{buffer}) ? bytes::length($self->{buffer}) : 0;
}


sub WRITE {
  my ($self, $scalar, $length, $offset) = @_;
  PRINT $self, substr($scalar, $offset||0, $length);
}


sub CLOSE {
  my ($self) = @_;
  untie *{$self->{out_fh}};
  $self->_print( $self->{buffer} ) if exists $self->{buffer};
  close $self->{tied_fh};
}


1;


__END__

=head1 NAME

IO::Pager::TiedStream - 

=head1 SYNOPSIS

  use IO::Pager::TiedStream;
  my $buffered = 0;
  tie *$fh, 'IO::Pager::TiedStream', $fh, $buffered;

=head1 DESCRIPTION

IO::Pager::TiedStream is a class to tie a filehandle and pipe its output
to the pager specified in the PAGER environment variable.

=head1 SEE ALSO

L<IO::Pager>, L<IO::Pager::Unbuffered>, L<IO::Pager::Unbuffered>,
L<IO::Pager::Page>

L<Tie::Handle>

=head1 AUTHOR

Jerrad Pierce <jpierce@cpan.org>

Florent Angly <florent.angly@gmail.com>

This module inspired by Monte Mitzelfelt's IO::Page 0.02

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
