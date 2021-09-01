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

#.say for to-long-format( @tbl0[^4], ["id"], ["passengerSex", "passengerClass", "passengerSurvival"], variablesTo => "VAR", valuesTo => "VAL2" );

.say for to-long-format( @tbl0[^4], [], [], variablesTo => "VAR", valuesTo => "VAL2" );

#.say for to-long-format( @tbl0[^4], [], 'AUTO', variablesTo => "VAR", valuesTo => "VAL2" );

#.say for to-long-format( @tbl0[^4], Nil, Nil, variablesTo => "VAR", valuesTo => "VAL2" );
