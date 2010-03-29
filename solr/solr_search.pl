#!/home/acme/bin/perl
# 
# This file is part of Metabase
# 
# This software is Copyright (c) 2010 by David Golden.
# 
# This is free software, licensed under:
# 
#   The Apache License, Version 2.0, January 2004
# 
use strict;
use warnings;
package main;
our $VERSION = '0.006';
use WebService::Solr;
use Perl6::Say;

my $query = shift || die "Usage: solr_search.pl roman_s:MCIX";

my $solr     = WebService::Solr->new();
my $response = $solr->search($query);
for my $doc ( $response->docs ) {
    say $doc->value_for('guid');
}

__END__
=pod

=head1 NAME

main

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

