#!/usr/bin/env perl6

use lib './lib';
use lib '.';

use Text::CSV;
use Data::Reshapers;
use Data::Reshapers::CrossTabulate;

##===========================================================
my $csv = Text::CSV.new;
my $fileName = $*CWD.Str ~ "/resources/dfTitanic.csv";

say "=" x 60;
say 'Array of hashes';
say "-" x 60;

my $tbl0 = $csv.csv(in => $fileName, headers => "auto");

say cross-tabulate($tbl0, 'passengerClass', 'passengerSex').raku;
say cross-tabulate($tbl0, 'passengerClass', 'passengerSex', 'passengerAge').raku;

say cross-tabulate($tbl0, 1, 3);

say "-" x 60;
say "Break it..";
say "-" x 60;

my @tbl0a = $tbl0.roll(40);
@tbl0a[2] = {id => 1, "sex" => "fem", "class" => "2nd", "status" => "lived", "age" => 43};

say @tbl0a;

say cross-tabulate(@tbl0a, "passengerSex", "passengerClass" );

say "=" x 60;
say 'Array of arrays';
say "-" x 60;

my @tbl1 = $csv.csv(in => $fileName, headers => "none");

say cross-tabulate(@tbl1, 1, 3);
say cross-tabulate(@tbl1, 1, 3, 2);

say cross-tabulate(@tbl1, 'passengerClass', 'passengerSex');

say "-" x 60;
say "Break it..";
say "-" x 60;

my @tbl1a = @tbl1.roll(40);
@tbl1a[2] = [1,"3","23","3","3"];

say @tbl1a;

say cross-tabulate(@tbl1a, 10, 3, 2);
say cross-tabulate(@tbl1a, 1, 3, 2);


say "=" x 60;
say 'Multi-dimensional array';
say "-" x 60;

srand(343);
my @inds = (1...5).roll(12);
my @rarr[12;5] = map { [<a b c d e> X~ $_] }, @inds;

say cross-tabulate( @rarr, 1, 3);

my $rlist = map { [<a b c d e> X~ $_]}, @inds;
say cross-tabulate( $rlist, 1, 3);
