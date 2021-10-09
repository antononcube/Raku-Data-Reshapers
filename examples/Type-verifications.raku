#!/usr/bin/env perl6

use lib './lib';
use lib '.';

use Data::Reshapers;
use Data::Reshapers::Predicates;

my @tbl0 = get-titanic-dataset(headers => 'auto');
my @tbl1 = get-titanic-dataset(headers => 'none');

say @tbl0[^2].gist;

@tbl0 = @tbl0.map({ $_<passengerAge> = $_<passengerAge>.Num; $_ });
@tbl1 = @tbl1.map({ $_[2] = $_[2].Num; $_ });

say @tbl0[^2].raku;
say to-pretty-table(@tbl0[^12].&record-types, title => '@tbl0[^12]');
say to-pretty-table(@tbl1[^12].&record-types, title => '@tbl1[^12]');

say '@tbl0.&has-homogeneous-shape : ', @tbl0.&has-homogeneous-shape;
say '@tbl0.&has-homogeneous-keys : ', @tbl0.&has-homogeneous-keys;
say '@tbl0.&has-homogeneous-hash-types : ', @tbl0[^12].&has-homogeneous-hash-types;

say '@tbl1.&has-homogeneous-shape : ', @tbl1.&has-homogeneous-shape;
say '@tbl1.&has-homogeneous-keys : ', @tbl1.&has-homogeneous-keys;
say '@tbl1.&has-homogeneous-array-types : ', @tbl1[^12].&has-homogeneous-array-types;
