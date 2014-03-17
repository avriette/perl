package Finance::Coinapult;

use 5.12.0;

"sic semper tyrannis";

# jane@cpan.org // vim:tw=80:ts=2:noet

=pod

=head1 NAME

Finance::Coinapult

=head1 ABSTRACT

Public API access for Coinapult in perl. Ta-da!

=head1 SYNOPSIS

  use Finance::Coinapult;
  my $c = Finance::Coinapult->new(
    key    => 'asdkjakjad',   # This is not actually a real key
    secret => 'sdlkjdlkjasd', # This is not actually a real secret
  );
  $c->get_balance(); # and so on

=head1 DESCRIPTION

C<Finance::Coinapult> aims to create a shiny perl package for interfacing
with the Coinapult public API.

=head1 ACCESSORS

Some C<accessors>

=head1 METHODS

Some C<methods>...

=head1 SEE ALSO

Stuff should go here.

=head1 BUGS

Bugs. Probably report them.

=head1 AUTHOR

Jane Avriette, E<lt>jane@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 by Jane Avriette

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.12.0 or,
at your option, any later version of Perl 5 you may have available.

=cut
