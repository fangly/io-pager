package IO::Pager::Unbuffered;
our $VERSION = 0.16;

use strict;
use base qw( IO::Pager );
use SelectSaver;


sub new(;$) {  # [FH]
  return 0 unless (my($class, $tied_fh) = &IO::Pager::_init);
  my $self = tie *$tied_fh, $class, $tied_fh or die "Could not tie $$tied_fh\n";

  { # Truly unbuffered
    my $saver = SelectSaver->new($self->{real_fh});
    $|=1;
  }
  return $self;
}

#Punt to base, preserving FH ($_[0]) for pass by reference to gensym
sub open(;$) { # [FH]
  IO::Pager::open($_[0], 'IO::Pager::Unbuffered');
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

See L<IO::Pager> for method details.

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

L<IO::Pager>, L<IO::Pager::Buffered>, L<IO::Pager::Page>,

=head1 AUTHOR

Jerrad Pierce <jpierce@cpan.org>

Florent Angly <florent.angly@gmail.com>

This module was inspired by Monte Mitzelfelt's IO::Page 0.02

Significant proddage provided by Tye McQueen.

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
