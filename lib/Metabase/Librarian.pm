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

package Metabase::Librarian;
BEGIN {
  $Metabase::Librarian::VERSION = '0.008';
}
# ABSTRACT: Front-end interface to Metabase storage

use Moose;
use Moose::Util::TypeConstraints;
use Carp ();
use CPAN::DistnameInfo;
use Metabase::Archive;
use Metabase::Index;
use Data::GUID ();
use JSON 2 ();

has 'archive' => (
    is => 'ro', 
    isa => 'Metabase::Archive',
    required => 1, 
);

has 'index' => (
    is => 'ro', 
    isa => 'Metabase::Index',
    required => 1, 
);

# given fact, store it and return guid; 
sub store {
    my ($self, $fact) = @_;

    # Facts must be assigned GUID at source
    unless ( $fact->guid ) {
        Carp::confess "Can't store: no GUID set for fact\n";
    }

    # Don't store existing GUIDs; this should never happen, since we're just
    # generating a new one, but... hey, can't be too safe, right?
    if ( $self->index->exists( $fact->guid ) ) {
        Carp::confess("GUID conflicts with an existing object");
    }

    # Updated the "update_time" timestamp
    $fact->touch;

    my $fact_struct = $fact->as_struct;

    # for Reports, store facts and replace content with GUID's
    # XXX nasty tight coupling with as_struct() -- dagolden, 2009-04-09
    if ( $fact->isa('Metabase::Report') ) {
      my @fact_guids;
      for my $f ( $fact->facts ) {
        push @fact_guids, $self->store( $f );
      }
      $fact_struct->{content} = JSON->new->ascii->encode(\@fact_guids);
    }

    if ( $self->archive->store( $fact_struct ) 
      && $self->index  ->add  ( $fact ) ) {
        return $fact->guid;
    } else {
        Carp::confess("Error storing or indexing fact with guid: " . $fact->guid);
    }
}

sub search {
    my ($self, %spec) = @_;
    return $self->index->search( %spec );
}

sub extract {
    my ($self, $guid) = @_;
    my $fact;

    my $fact_struct = $self->archive->extract( lc $guid );

    Carp::confess "Fact $guid does not exist" unless $fact_struct;

    # reconstruct fact meta and extract type to find the class
    my $class = Metabase::Fact->class_from_type(
      $fact_struct->{metadata}{core}{type}
    );
    
    # XXX: The problem here is that what we get out of the librarian isn't
    # exactly what we put in, it seems.  We need to improve the specification
    # for what goes in/out and then test it more thoroughly.  *Clearly* the
    # following block is a wretched hack. -- rjbs, 2009-06-24
    if ($class->isa('Metabase::Report')) {
      my @facts;
      my $content = JSON->new->ascii->decode( $fact_struct->{content} );
      for my $g ( @$content ) {
        # XXX no error checking if extract() fails -- dagolden, 2009-04-09
        push @facts, $self->extract( $g ); 
      }

      my $bogus_content = [ map { $_->as_struct } @facts ];
      my $bogus_string  = JSON->new->ascii->encode( $bogus_content );

      $fact = $class->from_struct({
        metadata => { core => $fact_struct->{metadata}{core} },
        content  => \$bogus_string,
      });
      $fact->close;
    }
    else {
      $fact = $class->from_struct( $fact_struct );
    }
    return $fact;
}

sub exists {
    my ($self, $guid) = @_;
    return $self->index->exists( lc $guid );
}

# DO NOT lc() the GUID -- we must allow deletion of improperly cased GUIDS from source
sub delete {
    my ($self, $guid) = @_;
    $self->index->delete( $guid );
    $self->archive->delete( $guid );
    return 1;
}

1;



=pod

=head1 NAME

Metabase::Librarian - Front-end interface to Metabase storage

=head1 VERSION

version 0.008

=head1 SYNOPSIS

  my $ml = Metabase::Librarian->new( 
    archive => $archive,
    index => $index,
  );

=head1 DESCRIPTION

The Metabase::Librarian class provides a front-end interface to user-defined
Metabase storage and indexing objects.

=for Pod::Coverage delete

=head1 USAGE

=head2 C<new>

  my $ml = Metabase::Librarian->new( 
    archive => $archive,
    index => $index,
  );

Librarian constructor.  Takes two required arguments

=over

=item *

C<archive> -- a Metabase::Archive subclass

=item *

C<index> -- a Metabase::Index subclass

=back

=head2 C<store>

  $ml->store( $fact );

=head2 C<search>

  $ml->search( %spec );

See L<Metabase::Index> for spec details.

=head2 C<extract>

  $fact = $ml->extract( $guid );

=head2 C<exists>

  if ( $ml->exists( $guid ) ) { do_stuff() }

=head1 BUGS

I<...no human would stack books this way...>

Please report any bugs or feature using the CPAN Request Tracker.  
Bugs can be submitted through the web interface at 
L<http://rt.cpan.org/Dist/Display.html?Queue=Metabase>

When submitting a bug or request, please include a test-file or a patch to an
existing test-file that illustrates the bug or desired feature.

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

