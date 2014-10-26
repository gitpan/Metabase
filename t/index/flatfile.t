# Copyright (c) 2008 by Ricardo Signes. All rights reserved.
# Licensed under terms of Perl itself (the "License").
# You may not use this file except in compliance with the License.
# A copy of the License was distributed with this file or you may obtain a 
# copy of the License from http://dev.perl.org/licenses/

use strict;
use warnings;

use Test::More;
use Test::Moose;

use Test::Exception;
use File::Temp ();
use File::Path ();

use lib 't/lib';
use Test::Metabase::Util;
my $TEST = Test::Metabase::Util->new;

plan tests => 16;

#-------------------------------------------------------------------------#

require_ok( 'Metabase::Index::FlatFile' );

ok( my $archive = $TEST->test_archive, 'created archive' );
does_ok( $archive, 'Metabase::Archive' );

ok( my $index = $TEST->test_index, 'created an index' );
does_ok( $index, 'Metabase::Index' );

ok( my $fact = $TEST->test_fact, "created a fact" );
isa_ok( $fact, 'Test::Metabase::StringFact' );

ok( my $guid = $archive->store( $fact->as_struct ), "stored a fact" );

my $fact2 = $archive->extract($guid);
ok ( $fact2->{metadata}{core}{guid}, "extracted a fact " );
is ( $fact2->{metadata}{core}{guid}, $fact->guid, "extracted a fact with the same guid" );

ok( $index->add( $fact ), "indexed fact" );

my $matches;
$matches = $index->search( 'core.guid' => $guid );
is( scalar @$matches, 1, "found guid searching for guid" );

$matches = $index->search( 'resource.cpan_id' => 'JOHNDOE' );
ok( scalar @$matches >= 1, "found guid searching for resource cpan_id" );

$matches = $index->search( 'core.type' => $fact->type );
ok( scalar @$matches >= 1, "found guid searching for fact type" );

$matches = $index->search( 'resource.author' => "asdljasljfa" );
is( scalar @$matches, 0, "found no guids searching for bogus dist_author" );

$matches = $index->search( bogus_key => "asdljasljfa" );
is( scalar @$matches, 0, "found no guids searching on bogus key" );

