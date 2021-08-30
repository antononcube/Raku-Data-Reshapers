#!/usr/bin/env perl6

use lib './lib';
use lib '.';

use Text::CSV;
use Data::Reshapers;

##===========================================================
my $csv = Text::CSV.new;
#my $fileName = %?RESOURCES<dfTitanic.csv>;
my $fileName = "/Volumes/Macintosh HD 1/Users/antonov/Raku-Data-Reshapers/resources/dfTitanic.csv";

say "=" x 60;
say 'Array of hashes';
say "-" x 60;

my @tbl0 = $csv.csv(in => $fileName, headers => "auto");

say cross-tabulate(@tbl0, 'passengerClass', 'passengerSex');
say cross-tabulate(@tbl0, 'passengerClass', 'passengerSex', 'passengerAge');

say cross-tabulate(@tbl0, 1, 3);


say "=" x 60;
say 'Array of arrays';
say "-" x 60;

my @tbl1 = $csv.csv(in => $fileName, headers => "none");

say cross-tabulate(@tbl1, 1, 3);
say cross-tabulate(@tbl1, 1, 3, 2);

say cross-tabulate(@tbl1, 'passengerClass', 'passengerSex');

my @tbl1a = @tbl1.roll(10);
@tbl1a[8] = [1,"3","23","3","3"];

say @tbl1a;

say cross-tabulate(@tbl1a, 10, 3, 2);
say cross-tabulate(@tbl1a, 1, 3, 2);