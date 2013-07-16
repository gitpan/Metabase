
use strict;
use warnings;

use 5.006;

use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "A database framework and API for resource metadata",
  "AUTHOR" => "David Golden <dagolden\@cpan.org>, Ricardo Signes <rjbs\@cpan.org>, Leon Brocard <acme\@cpan.org>",
  "BUILD_REQUIRES" => {},
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "Metabase",
  "EXE_FILES" => [],
  "LICENSE" => "apache",
  "NAME" => "Metabase",
  "PREREQ_PM" => {
    "CHI" => 0,
    "CPAN::DistnameInfo" => 0,
    "Carp" => 0,
    "Class::MOP" => 0,
    "Data::GUID" => 0,
    "Data::Stream::Bulk::Array" => 0,
    "Data::Stream::Bulk::Callback" => 0,
    "Data::Stream::Bulk::Filter" => 0,
    "Data::Stream::Bulk::Nil" => 0,
    "Fcntl" => 0,
    "File::Slurp" => 0,
    "IO::File" => 0,
    "JSON" => 2,
    "List::AllUtils" => 0,
    "Metabase::Fact" => "0.018",
    "Metabase::Fact::String" => 0,
    "Metabase::User::Profile" => 0,
    "Metabase::User::Secret" => 0,
    "Moose" => "1.00",
    "Moose::Role" => 0,
    "Moose::Util::TypeConstraints" => 0,
    "MooseX::Types::Moose" => 0,
    "MooseX::Types::Path::Class" => 0,
    "MooseX::Types::Structured" => 0,
    "Regexp::SQL::LIKE" => "0.001",
    "Test::Deep" => 0,
    "Test::More" => "0.92",
    "Test::Routine" => 0,
    "Tie::File" => 0,
    "namespace::autoclean" => 0,
    "parent" => 0,
    "strict" => 0,
    "warnings" => 0
  },
  "TEST_REQUIRES" => {
    "ExtUtils::MakeMaker" => 0,
    "File::Find" => 0,
    "File::Path" => 0,
    "File::Spec::Functions" => 0,
    "File::Temp" => 0,
    "List::Util" => 0,
    "Metabase::Report" => 0,
    "Path::Class" => 0,
    "Test::Exception" => 0,
    "Test::Routine::Util" => 0,
    "base" => 0,
    "lib" => 0
  },
  "VERSION" => "1.002",
  "test" => {
    "TESTS" => "t/*.t t/archive/*.t t/gateway/*.t t/index/*.t t/librarian/*.t"
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.63_03) } ) {
  my $tr = delete $WriteMakefileArgs{TEST_REQUIRES};
  my $br = $WriteMakefileArgs{BUILD_REQUIRES};
  for my $mod ( keys %$tr ) {
    if ( exists $br->{$mod} ) {
      $br->{$mod} = $tr->{$mod} if $tr->{$mod} > $br->{$mod};
    }
    else {
      $br->{$mod} = $tr->{$mod};
    }
  }
}

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



