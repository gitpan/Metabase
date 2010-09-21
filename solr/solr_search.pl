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
use WebService::Solr;
use Perl6::Say;

my $query = shift || die "Usage: solr_search.pl roman_s:MCIX";

my $solr     = WebService::Solr->new();
my $response = $solr->search($query);
for my $doc ( $response->docs ) {
    say $doc->value_for('guid');
}
