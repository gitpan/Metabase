# 
# This file is part of Metabase
# 
# This software is Copyright (c) 2010 by David Golden.
# 
# This is free software, licensed under:
# 
#   The Apache License, Version 2.0, January 2004
# 
use 5.006;
use strict;
use warnings;

package Metabase::Archive::Schema;
our $VERSION = '0.006';
use strict;
use warnings;
use base qw/DBIx::Class::Schema/;

__PACKAGE__->load_classes(qw/Fact/);

1;

__END__
=pod

=head1 NAME

Metabase::Archive::Schema

=head1 VERSION

version 0.006

=head1 AUTHORS

  David Golden <dagolden@cpan.org>
  Ricardo Signes <rjbs@cpan.org>
  Leon Brocard <acme@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2010 by David Golden.

This is free software, licensed under:

  The Apache License, Version 2.0, January 2004

=cut

