#!/usr/bin/env perl6

use lib './lib';
use lib '.';

use Text::CSV;
use Data::Reshapers;
use Data::Reshapers::ToLongFormat;
use Data::Reshapers::ToWideFormat;

##===========================================================
my $csv = Text::CSV.new;
my $fileName = $*CWD.Str ~ "/resources/dfTitanic.csv";

say "=" x 60;
say 'Array of hashes';
say "-" x 60;

my @tbl0 = $csv.csv(in => $fileName, headers => "auto");

#.say for to-long-format( @tbl0[^4], ["id"], ["passengerSex", "passengerClass", "passengerSurvival"], variablesTo => "VAR", valuesTo => "VAL2" );

say "=" x 60;
say "Sample data";
say "-" x 60;

.say for @tbl0[^4];

say "=" x 60;
say "To long format";
say "-" x 60;

my @res = to-long-format( @tbl0[^4], [], [], variablesTo => "VAR", valuesTo => "VAL2" );

.say for @res;

#.say for to-long-format( @tbl0[^4], [], 'AUTO', variablesTo => "VAR", valuesTo => "VAL2" );

#.say for to-long-format( @tbl0[^4], Nil, Nil, variablesTo => "VAR", valuesTo => "VAL2" );

say "=" x 60;
say "To wide format";
say "-" x 60;

my @wres = to-wide-format( @res, "AutomaticKey", "VAR", "VAL2");

.say for @wres;