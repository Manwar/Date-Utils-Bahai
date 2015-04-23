#!perl

use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More tests => 1;

BEGIN { use_ok('Date::Utils::Bahai') || print "Bail out!"; }

diag( "Testing Date::Utils::Bahai $Date::Utils::Bahai::VERSION, Perl $], $^X" );
