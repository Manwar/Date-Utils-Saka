#!/usr/bin/perl

package T::Date::Utils::Saka;

use Moo;
use namespace::clean;

with 'Date::Utils::Saka';

package main;

use 5.006;
use Test::More tests => 12;
use strict; use warnings;

my $t = T::Date::Utils::Saka->new;

ok($t->validate_year(1937));
eval { $t->validate_year(-1937); };
like($@, qr/ERROR: Invalid year \[\-1937\]./);

ok($t->validate_month(11));
eval { $t->validate_month(13); };
like($@, qr/ERROR: Invalid month \[13\]./);

ok($t->validate_day(30));
eval { $t->validate_day(32); };
like($@, qr/ERROR: Invalid day \[32\]./);

is($t->saka_to_julian(1937, 1, 1), 2457103.5);
is(join(', ', $t->julian_to_saka(2457103.5)), '1937, 1, 1');

is(sprintf("%04d-%02d-%02d", $t->saka_to_gregorian(1937, 1, 1)), '2015-03-22');
is(join(', ', $t->gregorian_to_saka(2015, 3, 22)), '1937, 1, 1');

is($t->days_in_saka_month_year(1, 1937), 30);
is($t->days_in_chaitra(1937), 30);

done_testing;
