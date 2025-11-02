#!/usr/bin/env perl6

# use lib <. lib>

use Data::Reshapers;
use Data::Reshapers::ToLongFormat;
use Data::Reshapers::ToWideFormat;

##===========================================================
say "=" x 60;
say 'Array of hashes';
say "-" x 60;

my @tbl0 = get-titanic-dataset( headers => 'auto') ;
say @tbl0.elems, ' ', @tbl0[0].keys.elems;

#.say for to-long-format( @tbl0[^4], ["id"], ["passengerSex", "passengerClass", "passengerSurvival"], variablesTo => "VAR", valuesTo => "VAL2" );

say "=" x 60;
say "Sample data";
say "-" x 60;

my @tbl1 = @tbl0.roll(5);

.say for @tbl1;

say "=" x 60;
say "To long format";
say "-" x 60;

say 'before @tbl1[0] : ', @tbl1[0];

my @lfRes = to-long-format( @tbl1, [], [], variablesTo => "VAR", valuesTo => "VAL2" );

say 'after @tbl1[0] : ', @tbl1[0];

.say for @lfRes;

#.say for to-long-format( @tbl0[^4], [], 'AUTO', variablesTo => "VAR", valuesTo => "VAL2" );

#.say for to-long-format( @tbl0[^4], Nil, Nil, variablesTo => "VAR", valuesTo => "VAL2" );

say "=" x 60;
say "To wide format";
say "-" x 60;

my @wfRes = to-wide-format( @lfRes, "AutomaticKey", "VAR", "VAL2");

.say for @wfRes;