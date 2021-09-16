#!/usr/bin/env perl6

use lib './lib';
use lib '.';

use Data::Reshapers;

my @tbl0 = get-titanic-dataset(headers => 'auto');
my @tbl1 = get-titanic-dataset(headers => 'none');

say "=" x 30;
say "Hash of hashes";
say "=" x 30;

my %res = cross-tabulate(@tbl0, 'passengerSex', 'passengerSurvival');
say %res.gist;
my %tres = transpose( %res );
say %tres.gist;

say to-pretty-table(%res, title => "Original");

say to-pretty-table(%tres, title => "Transposed");

say "=" x 30;
say "Array of hashes";
say "=" x 30;

my @tbl3 = @tbl0.roll(3);
say @tbl3.raku;

say to-pretty-table(@tbl3, title => "Original");

say transpose(@tbl3).raku;

#.say for transpose(@tbl3);
say to-pretty-table(transpose(@tbl3), title => "Transposed");

say "=" x 30;
say "Array of arrays";
say "=" x 30;

my @tbl4 = @tbl1.roll(7);

say @tbl4.raku;
say to-pretty-table(@tbl4, title => "Original");

say transpose(@tbl4).raku;
say to-pretty-table(transpose(@tbl4), title => "Transposed");
