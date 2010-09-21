
use strict;
use warnings;

 BEGIN { require 5.006; } 

use ExtUtils::MakeMaker 6.31;



my %WriteMakefileArgs = (
  'ABSTRACT' => 'A database framework and API for resource metadata',
  'AUTHOR' => 'David Golden <dagolden@cpan.org>, Ricardo Signes <rjbs@cpan.org>, Leon Brocard <acme@cpan.org>',
  'BUILD_REQUIRES' => {
    'File::Find' => '0',
    'File::Path' => '0',
    'File::Temp' => '0',
    'Metabase::Fact::String' => '0',
    'Metabase::Report' => '0',
    'Test::Exception' => '0',
    'Test::Moose' => '0',
    'Test::More' => '0.88'
  },
  'CONFIGURE_REQUIRES' => {
    'ExtUtils::MakeMaker' => '6.31'
  },
  'DISTNAME' => 'Metabase',
  'EXE_FILES' => [],
  'LICENSE' => 'apache',
  'NAME' => 'Metabase',
  'PREREQ_PM' => {
    'CHI' => '0',
    'CPAN::DistnameInfo' => '0',
    'Carp' => '0',
    'Class::MOP' => '0',
    'Compress::Zlib' => '2',
    'DBD::SQLite' => '1',
    'DBI' => '1',
    'DBIx::Class' => '0',
    'DBIx::Class::Schema' => '0',
    'Data::GUID' => '0',
    'Data::Stream::Bulk::Filter' => '0',
    'Fcntl' => '0',
    'File::Slurp' => '0',
    'IO::File' => '0',
    'JSON' => '2',
    'Metabase::Fact' => '0.018',
    'Metabase::User::Profile' => '0',
    'Metabase::User::Secret' => '0',
    'Moose' => '1.00',
    'Moose::Role' => '0',
    'Moose::Util::TypeConstraints' => '0',
    'MooseX::Types::Path::Class' => '0',
    'Net::Amazon::S3' => '0',
    'Path::Class' => '0',
    'SQL::Abstract' => '1',
    'SimpleDB::Client' => '0',
    'Try::Tiny' => '0',
    'WebService::Solr' => '0',
    'namespace::autoclean' => '0'
  },
  'VERSION' => '0.014',
  'test' => {
    'TESTS' => 't/*.t t/gateway/*.t t/index/*.t t/librarian/*.t t/storage/*.t'
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



