#!/usr/bin/env perl6

use Data::Reshapers;
use Data::Generators;

#============================================================
# Data generation
#============================================================

my @dfData0 = random-tabular-dataset(4, <alpha beta gamma delta>, generators=>[ -> $x { ((^200).rand xx $x).Array }, &random-pet-name]);
my %dfData1 = random-tabular-dataset(4, <alpha beta gamma delta>, generators=>[ -> $x { ((^200).rand xx $x).Array }, &random-pet-name], :row-names);

say '#============================================================';
say '# Array of hashes';
say '#============================================================';

say to-pretty-table(@dfData0, junction-char => 'O', float-format=> '6.3f');

say to-pretty-table(rename-columns(@dfData0, { delta => 'ura', 'beta' => 'B'}));

say to-pretty-table(select-columns(@dfData0, <delta gamma>) );

say to-pretty-table(select-columns(%dfData1.pairs, <delta gamma>) );

say to-pretty-table(rename-columns(@dfData0, 'beta' => 'CIGAR'));
say to-pretty-table(rename-columns(%dfData1, 'beta' => 'CIGAR'));

say to-pretty-table(select-columns(@dfData0, { delta => 'DELTA', 'beta' => 'BETA'}),
        junction-char => 'O', float-format=> '3.3f');

say rename-columns(@dfData0, { delta => 'ura', 'beta' => 'B'}).raku;
say rename-columns(@dfData0, { delta => 'ura', 'beta' => 'B'})>>.keys.raku;

say rename-columns(@dfData0, { delta => 'ura', 'beta' => 'B'})>>.keys>>.Array.unique(:as({ $_.sort.Array }):with(&[eqv]))>>.sort;

say '#------------------------------------------------------------';
say "# delete columns \n";

say to-pretty-table(delete-columns(@dfData0, 'delta'));

say to-pretty-table(delete-columns(@dfData0, <delta beta>));

say '#============================================================';
say '# Hash of hashes';
say '#============================================================';

say to-pretty-table(%dfData1);


my %res2 = rename-columns(%dfData1, { delta => 'ura', 'beta' => 'B'});

say to-pretty-table(%res2);

say rename-columns(%dfData1, { delta => 'ura', 'beta' => 'B'}).values>>.keys>>.Array.unique(:as({ $_.sort.Array }):with(&[eqv]))>>.sort;
say '%res2.pairs.pick : ', %res2.pairs.pick.value.Set;
say '[(&)] %res2.values>>.Set : ', [(&)] %res2.values>>.Set;
say 'Verification same: ', ( [(&)] %res2.values>>.Set ) eqv %res2.pairs.pick.value.Set;

say '#------------------------------------------------------------';
say "# delete columns \n";

say to-pretty-table(delete-columns(%dfData1, 'delta'));

say to-pretty-table(delete-columns(%dfData1, <delta beta>));

