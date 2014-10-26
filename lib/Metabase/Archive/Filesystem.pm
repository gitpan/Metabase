use 5.006;
use strict;
use warnings;

package Metabase::Archive::Filesystem;
# ABSTRACT: Metabase filesystem-based storage
our $VERSION = '1.003'; # VERSION

use Moose;
use Moose::Util::TypeConstraints;

use Metabase::Fact;
use Carp ();
use Data::Stream::Bulk::Callback;
use Data::GUID ();
use File::Slurp ();
use JSON 2 ();
use MooseX::Types::Path::Class;

with 'Metabase::Archive';

has 'root_dir' => (
    is => 'ro',
    isa => 'Path::Class::Dir',
    coerce => 1,
    required => 1,
);

# Ensure we have a directory we can write to
sub initialize {
  my ($self, @fact_classes) = @_;
  my $dir = $self->root_dir;
  if ( -d $dir && -w $dir ) {
    return;
  }
  elsif ( ! -d $dir ) {
    $dir->mkpath;
    Carp::confess "Could not create directory '$dir': $!"
      unless -d $dir;
  }
  else {
    Carp::confess "Directory '$dir' not writeable";
  }
}

# given fact, store it and return guid; return
# XXX can we store a fact with a GUID already?  Replaces?  Or error?
# here assign only if no GUID already
sub store {
    my ($self, $fact_struct) = @_;

    my $guid = $fact_struct->{metadata}{core}{guid};
    unless ( $guid ) {
        Carp::confess "Can't store: no GUID set for fact\n";
    }

    # freeze and write the fact
    File::Slurp::write_file(
        $self->_guid_path( $guid ),
        {binmode => ':raw'},
        JSON->new->ascii->encode($fact_struct),
    );

    return $guid;
}

# given guid, retrieve it and return it
# type is directory path
# class isa Metabase::Fact::Subclass
sub extract {
    my ($self, $guid) = @_;
    return $self->_extract_file( $self->_guid_path($guid) );
}

sub _extract_file {
  my ($self, $file) = @_;
  # read the fact
  my $fact_struct = JSON->new->ascii->decode(
    File::Slurp::read_file( $file, { binmode => ':raw' } ),
  );
  return $fact_struct;
}

sub delete {
  my ($self, $guid) = @_;
  unlink $self->_guid_path( $guid );
}

sub iterator {
  my ($self) = @_;
  my @queue = map { $_->children } $self->root_dir->children;
  return Data::Stream::Bulk::Callback->new(
    callback => sub {
      my $d = shift @queue;
      if ($d) {
        my @results;
        $d->recurse(
          callback => sub {
            my $f = shift;
            push @results, $self->_extract_file($f) if ! $f->is_dir
          }
        );
        return \@results;
      }
      else {
        return;
      }
    }
  );
}

sub _guid_path {
    my ($self, $guid) = @_;

    # convert guid from "abc-def-ghi" => "abc/def" as a place to put the file
    my $guid_path = lc $guid;
    $guid_path =~ s{-}{/}g;
    $guid_path =~ s{/\w+$}{};
    my $fact_path = Path::Class::file( $self->root_dir, $guid_path, $guid );
    $fact_path->dir->mkpath;

    return $fact_path->stringify;
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Metabase::Archive::Filesystem - Metabase filesystem-based storage

=head1 VERSION

version 1.003

=head1 SYNOPSIS

  require Metabase::Archive::Filesystem;

  $archive = Metabase::Archive::Filesystem->new(
    root_dir => $storage_directory
  );

=head1 DESCRIPTION

Store facts as files in the filesystem, hashed into a directory tree by GUID to
manage the number of files in any particular directory.

=head1 USAGE

See L<Metabase::Archive> and L<Metabase::Librarian>.

=for Pod::Coverage store extract delete initialize iterator

=head1 AUTHORS

=over 4

=item *

David Golden <dagolden@cpan.org>

=item *

Ricardo Signes <rjbs@cpan.org>

=item *

Leon Brocard <acme@cpan.org>

=back

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2013 by David Golden.

This is free software, licensed under:

  The Apache License, Version 2.0, January 2004

=cut
