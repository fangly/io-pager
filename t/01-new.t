#!/usr/bin/perl -w

use strict;
use warnings;
use Test::More tests => 2;
use IO::Pager;
use Test::NoWarnings;

ok my $pager = IO::Pager->new(\*STDOUT), 'Connect to STDOUT';
