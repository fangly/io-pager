package IO::Pager::TiedStream;

use 5;
use strict;
use Env qw( PAGER );
use base qw( Tie::Handle );

our $VERSION = 0.10;




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
