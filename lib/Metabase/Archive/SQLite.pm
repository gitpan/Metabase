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

package Metabase::Archive::SQLite;
BEGIN {
  $Metabase::Archive::SQLite::VERSION = '0.009';
}
# ABSTRACT: Metabase storage using SQLite

use Moose;
use Moose::Util::TypeConstraints;
use MooseX::Types::Path::Class;

use Metabase::Fact;
use Carp        ();
use Data::GUID  ();
use JSON 2      ();
use Path::Class ();
use DBI         ();
use DBD::SQLite ();
use Compress::Zlib qw(compress uncompress);
use Metabase::Archive::Schema;

with 'Metabase::Archive';

has 'filename' => (
    is       => 'ro',
    isa      => 'Path::Class::File',
    coerce   => 1,
    required => 1,
);

has 'compressed' => (
    is      => 'rw',
    isa     => 'Bool',
    default => 1,
);

has 'schema' => (
    is      => 'ro',
    isa     => 'Metabase::Archive::Schema',
    lazy    => 1,
    default => sub {
        my $self     = shift;
        my $filename = $self->filename;
        my $exists   = -f $filename;
        my $schema   = Metabase::Archive::Schema->connect(
            "dbi:SQLite:$filename",
            "", "",
            {   RaiseError => 1,
                AutoCommit => 1,
            },
        );
        $schema->deploy unless $exists;
        return $schema;
    },
);

# given fact, store it and return guid; return
# XXX can we store a fact with a GUID already?  Replaces?  Or error?
# here assign only if no GUID already
sub store {
    my ( $self, $fact_struct ) = @_;
    my $guid = lc $fact_struct->{metadata}{core}{guid};
    my $type = $fact_struct->{metadata}{core}{type};

    unless ($guid) {
        Carp::confess "Can't store: no GUID set for fact\n";
    }

    my $content = $fact_struct->{content};
    my $json    = eval { JSON->new->ascii->encode($fact_struct->{metadata}{core}) };
    Carp::confess "Couldn't convert to JSON: $@"
      unless $json;

    if ( $self->compressed ) {
        $json    = compress($json);
        $content = compress($content);
    }

    $self->schema->resultset('Fact')->create(
        {   guid    => $guid,
            type    => $type,
            meta    => $json,
            content => $content,
        }
    );

    return $guid;
}

# given guid, retrieve it and return it
# type is directory path
# class isa Metabase::Fact::Subclass
sub extract {
    my ( $self, $guid ) = @_;
    my $schema = $self->schema;

    my $fact = $schema->resultset('Fact')->find(lc $guid);
    return undef unless $fact;

    my $type    = $fact->type;
    my $json    = $fact->meta;
    my $content = $fact->content;

    if ( $self->compressed ) {
        $json    = uncompress($json);
        $content = uncompress($content);
    }

    my $meta = JSON->new->ascii->decode($json);

    # reconstruct fact meta and extract type to find the class
    my $class = Metabase::Fact->class_from_type($type);

    return { 
      content => $content, 
      metadata => {
        core => $meta
      },
    };
}

1;



=pod

=head1 NAME

Metabase::Archive::SQLite - Metabase storage using SQLite

=head1 VERSION

version 0.009

=head1 SYNOPSIS

  require Metabase::Archive::SQLite;

  $archive = Metabase::Archive::SQLite->new(
    filename => $sqlite_file,
  ); 

=head1 DESCRIPTION

Store facts in a SQLite database.

=for Pod::Coverage::TrustPod store extract

=head1 USAGE

See L<Metabase::Archive> and L<Metabase::Librarian>.

TODO: document optional C<compressed> option (default 1) and
C<schema> option (sensible default provided).

=head1 BUGS

Please report any bugs or feature using the CPAN Request Tracker.  
Bugs can be submitted through the web interface at 
L<http://rt.cpan.org/Dist/Display.html?Queue=Metabase>

When submitting a bug or request, please include a test-file or a patch to an
existing test-file that illustrates the bug or desired feature.

=head1 COPYRIGHT AND LICENSE

 Portions Copyright (c) 2008-2009 by Leon Brocard

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

