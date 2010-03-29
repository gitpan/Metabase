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
use Text::Roman;
use WebService::Solr;
use Term::ProgressBar::Simple;

my $count = 10_000;

my $progress = Term::ProgressBar::Simple->new($count);

my $solr = WebService::Solr->new( undef, { autocommit => 0 } );

my @docs;
foreach my $i ( 1 .. $count ) {
    my $doc = WebService::Solr::Document->new;
    $doc->add_fields(
        guid    => $i,
        type    => 'roman',
        roman_s => roman($i),
    );
    push @docs, $doc;
    $progress++;

    # add in bunches of a thousand
    if ( @docs == 1_000 ) {
        $solr->add( \@docs );
        @docs = ();
    }
}
$solr->commit;
$solr->optimize;

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

