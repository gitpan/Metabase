#
# This file is part of Metabase
#
# This software is Copyright (c) 2010 by David Golden.
#
# This is free software, licensed under:
#
#   The Apache License, Version 2.0, January 2004
#
package Test::Metabase::Report;
use 5.006;
use strict;
use warnings;
use base 'Metabase::Report';

__PACKAGE__->load_fact_classes;

sub report_spec {
  return {
    'Test::Metabase::StringFact' => "1+",  # zero or more
  }
}

1;
