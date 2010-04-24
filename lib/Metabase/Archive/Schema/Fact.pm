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

package Metabase::Archive::Schema::Fact;
BEGIN {
  $Metabase::Archive::Schema::Fact::VERSION = '0.011';
}

use base qw/DBIx::Class/;
__PACKAGE__->load_components(qw/PK ResultSourceProxy::Table/);

__PACKAGE__->table('fact');
__PACKAGE__->add_columns(
    guid => {
        data_type   => 'char',
        size        => 36,
        is_nullable => 0,
        is_unique   => 1,
    },
    type => {
        data_type   => 'varchar',
        is_nullable => 0,
    },
    meta => {
        data_type   => 'varchar',
        is_nullable => 0,
    },
    content => {
        data_type   => 'blob',
        is_nullable => 0,
    }
);
__PACKAGE__->set_primary_key('guid');

1;

__END__
=pod

=head1 NAME

Metabase::Archive::Schema::Fact

=head1 VERSION

version 0.011

=head1 AUTHORS

  David Golden <dagolden@cpan.org>
  Ricardo Signes <rjbs@cpan.org>
  Leon Brocard <acme@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2010 by David Golden.

This is free software, licensed under:

  The Apache License, Version 2.0, January 2004

=cut

