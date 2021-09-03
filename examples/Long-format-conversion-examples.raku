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

my @tbl1 = @tbl0.roll(5);

.say for @tbl1;

say "=" x 60;
say "To long format";
say "-" x 60;

my @lfRes = to-long-format( @tbl1, [], [], variablesTo => "VAR", valuesTo => "VAL2" );

.say for @lfRes;

#.say for to-long-format( @tbl0[^4], [], 'AUTO', variablesTo => "VAR", valuesTo => "VAL2" );

#.say for to-long-format( @tbl0[^4], Nil, Nil, variablesTo => "VAR", valuesTo => "VAL2" );

say "=" x 60;
say "To wide format";
say "-" x 60;

my @wfRes = to-wide-format( @lfRes, "AutomaticKey", "VAR", "VAL2");

.say for @wfRes;