
use strict;
use warnings;

 BEGIN { require 5.006; } 

use ExtUtils::MakeMaker 6.31;



my %WriteMakefileArgs = (
                       'test' => {
                                   'TESTS' => 't/gateway/*.t t/index/*.t t/librarian/*.t t/storage/*.t'
                                 },
                       'NAME' => 'Metabase',
                       'DISTNAME' => 'Metabase',
                       'CONFIGURE_REQUIRES' => {
                                                 'ExtUtils::MakeMaker' => '6.31'
                                               },
                       'AUTHOR' => 'David Golden <dagolden@cpan.org>, Ricardo Signes <rjbs@cpan.org>, Leon Brocard <acme@cpan.org>',
                       'BUILD_REQUIRES' => {},
                       'ABSTRACT' => 'A database framework and API for resource metadata',
                       'EXE_FILES' => [],
                       'VERSION' => '0.009',
                       'PREREQ_PM' => {
                                        'CPAN::DistnameInfo' => '0',
                                        'Metabase::User::Profile' => '0',
                                        'File::Path' => '0',
                                        'DBI' => '1',
                                        'Try::Tiny' => '0',
                                        'SimpleDB::Class::HTTP' => '0',
                                        'SQL::Abstract' => '1',
                                        'Moose::Role' => '0',
                                        'Test::Exception' => '0',
                                        'IO::File' => '0',
                                        'DBIx::Class::Schema' => '0',
                                        'Test::More' => '0.88',
                                        'MooseX::Types::Path::Class' => '0',
                                        'File::Temp' => '0.20',
                                        'Path::Class' => '0',
                                        'Metabase::Fact::String' => '0',
                                        'Compress::Zlib' => '2',
                                        'DBD::SQLite' => '1',
                                        'Fcntl' => '0',
                                        'Metabase::User::Secret' => '0',
                                        'Moose::Util::TypeConstraints' => '0',
                                        'Data::GUID' => '0',
                                        'Test::Moose' => '0',
                                        'DBIx::Class' => '0',
                                        'File::Slurp' => '9999',
                                        'Metabase::Fact' => '0',
                                        'Moose' => '0',
                                        'namespace::autoclean' => '0',
                                        'Net::Amazon::S3' => '0',
                                        'Carp' => '0',
                                        'Metabase::Report' => '0',
                                        'JSON' => '2'
                                      },
                       'LICENSE' => 'apache'
                     );


delete $WriteMakefileArgs{BUILD_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.56) };

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



