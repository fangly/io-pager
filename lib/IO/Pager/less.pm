package IO::Pager::less;
our $VERSION = 0.30;

use strict;
#use base qw( IO::Handle );
use base qw( IO::Pager );

sub new{#[FH], [Buffered?]
#    warn join(',',@_);
#    my $FH = defined($_[0]) ?
#	IO::Handle->new_from_fd(fileno($_[0]), 'w') :
#	IO::Handle->new->fdopen(Symbol::gensym(), 'w');
#    use Data::Dumper 'Dumper'; print Dumper $FH;
#    $FH->autoflush(1) if $_[1];
##    return bless $FH, 'IO::Pager::less';
#    return $FH;
  my($class, $tied_fh) = @_;
  tie *$tied_fh, $class, $tied_fh or return 0;
}

sub TIEHANDLE{

}

1;

__END__

=head1 NAME

IO::Pager::less - (OO) pagerless output, not output with the less(1) pager

=head1 SYNOPSIS

See L<IO::Pager>

=head1 DESCRIPTION

This is a stub class that is not meant to be invoked directly.
It provides transparent fallback for OO methods when not connected
to a TTY by inherting methods from L<IO::Handle>.

=head1 SEE ALSO

L<IO::Pager::Buffered>,  L<IO::Pager::Unbuffered>

=head1 AUTHOR

Jerrad Pierce <jpierce@cpan.org>

This module was inspired by Monte Mitzelfelt's IO::Page 0.02

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 Jerrad Pierce

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
