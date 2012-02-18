use strict;
use warnings;
use Test::More;
use t::TestUtils;

# Test that all modules load properly

BEGIN {
  use_ok('IO::Pager');
  use_ok('IO::Pager::Unbuffered');
  use_ok('IO::Pager::Buffered');
  use_ok('IO::Pager::Page');
};

done_testing;
