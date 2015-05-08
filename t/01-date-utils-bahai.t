#!/usr/bin/perl

package T::Date::Utils::Bahai;

use Moo;
use namespace::clean;

with 'Date::Utils::Bahai';

package main;

use 5.006;
use Test::More tests => 8;
use strict; use warnings;

my $t = T::Date::Utils::Bahai->new;

eval { $t->validate_year(-168); };
like($@, qr/ERROR: Invalid year \[\-168\]./);

eval { $t->validate_month(20); };
like($@, qr/ERROR: Invalid month \[20\]./);

eval { $t->validate_day(20); };
like($@, qr/ERROR: Invalid day \[20\]./);

my @b_gregorian = $t->bahai_to_gregorian(1, 10, 1, 2, 8);
is(join(", ", @b_gregorian), '2015, 4, 16');

my @g_bahai = $t->gregorian_to_bahai(2015, 4, 16);
is(join(", ", @g_bahai), '1, 10, 1, 2, 8');

my @j_bahai = $t->julian_to_bahai(2457102.5);
is(join(", ", @j_bahai), '1, 10, 1, 1, 1');

is($t->bahai_to_julian(1, 10, 1, 1, 1), 2457102.5);

my @bahai = $t->get_major_cycle_year(171);
is(join(", ", @bahai), '1, 10, 1');

done_testing;
