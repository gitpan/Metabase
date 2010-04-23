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

package Metabase::Index::Solr;
BEGIN {
  $Metabase::Index::Solr::VERSION = '0.010';
}
# ABSTRACT: Metabase Solr index

use Moose;
use WebService::Solr;

with 'Metabase::Index';

has 'solr' => (
    is      => 'ro',
    isa     => 'WebService::Solr',
    lazy    => 1,
    default => sub {
        WebService::Solr->new( undef, { autocommit => 0 } );
    },
);

sub add {
    my ( $self, $fact ) = @_;
    my $solr = $self->solr;

    Carp::confess("can't index a Fact without a GUID") unless $fact->guid;

    my %metadata = (
        'core.type_s'           => $fact->type,
        'core.schema_version_i' => $fact->schema_version,
        'core.guid_s'           => lc $fact->guid,
        'core.created_at_i'     => $fact->created_at,
    );

    for my $category (qw(content resource)) {
        my $meta_method = "$category\_metadata";
        my $types_method = "$category\_metadata_types";
        my $data = $fact->$meta_method || {};
        my $types = $fact->$types_method || {};

        for my $key ( keys %$data ) {

          # I'm just starting with a strict-ish set.  We can tighten or loosen
          # parts of this later. -- rjbs, 2009-03-28
            die "invalid metadata key" unless $key =~ /\A[-_a-z0-9.]+\z/;
            my $type  = $types->{$key};
            my $value = $data->{$key};
            if ( $type eq '//str' ) {
                $metadata{"$category.$key\_s"} = $value;
            } elsif ( $type eq '//num' ) {
                $metadata{"$category.$key\_i"} = $value;
            } else {
                confess "Unknown type $type";
            }
        }
    }

    my $doc = WebService::Solr::Document->new;
    $doc->add_fields(%metadata);
    $solr->add($doc);
    $solr->commit;

    # $solr->optimize;
}

sub search {
    my ( $self, %spec ) = @_;
    my $solr = $self->solr;

    my $query;
    if ( $spec{'core.guid'} ) {
        $query = "core.guid_s:" . $spec{'core.guid'};
    } elsif ( $spec{'core.type'} ) {
        $query = "core.type_s:" . $spec{'core.type'};
    } else {
        warn "other query";
        return [];
    }

    my @matches;
    my $response = $solr->search($query);
    for my $doc ( $response->docs ) {
        push @matches, $doc->value_for('core.guid_s');
    }

    return \@matches;
}

sub exists {
    my ( $self, $guid ) = @_;

    return scalar @{ $self->search( 'core.guid' => lc $guid ) };
}

1;



=pod

=head1 NAME

Metabase::Index::Solr - Metabase Solr index

=head1 VERSION

version 0.010

=head1 SYNOPSIS

    require Metabase::Index::Solr;

    my $index = Metabase::Index::Solr->new(
      solr => $solr_obj, # WebService::Solr
    );

=head1 DESCRIPTION

Metabase index using L<WebService::Solr>.

=for Pod::Coverage::TrustPod add search exists

=head1 USAGE

See L<Metabase::Index> and L<Metabase::Librarian>.

=head1 BUGS

Please report any bugs or feature using the CPAN Request Tracker.  
Bugs can be submitted through the web interface at 
L<http://rt.cpan.org/Dist/Display.html?Queue=Metabase>

When submitting a bug or request, please include a test-file or a patch to an
existing test-file that illustrates the bug or desired feature.

=head1 COPYRIGHT AND LICENSE

 Portions Copyright (c) 2009 by Leon Brocard

Licensed under terms of Perl itself (the "License").
You may not use this file except in compliance with the License.
A copy of the License was distributed with this file or you may obtain a 
copy of the License from http://dev.perl.org/licenses/

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

=head1 AUTHORS

  David Golden <dagolden@cpan.org>
  Ricardo Signes <rjbs@cpan.org>
  Leon Brocard <acme@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2010 by David Golden.

This is free software, licensed under:

  The Apache License, Version 2.0, January 2004

=cut


__END__

