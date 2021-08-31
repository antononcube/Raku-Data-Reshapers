#!/usr/bin/env perl6

use lib './lib';
use lib '.';

use Text::CSV;
use Data::Reshapers;
use Data::Reshapers::ToLongFormat;

##===========================================================
my $csv = Text::CSV.new;
my $fileName = $*CWD.Str ~ "/resources/dfTitanic.csv";

say "=" x 60;
say 'Array of hashes';
say "-" x 60;

my @tbl0 = $csv.csv(in => $fileName, headers => "auto");

put to-long-format( @tbl0, ["id"], ["passengerSex", "passengerClass", "passengerSurvival"] );
