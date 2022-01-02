#!/usr/bin/env perl6

use lib './lib';
use lib '.';

use Data::Reshapers;
use Data::Generators;

#============================================================
# Data generation
#============================================================

my @dfData0 =
        random-tabular-dataset(12,
                <misnomer tank flower puma>,
                generators => { misnomer => -> $x { (rand xx $x).Array },
                                tank => random-pet-name(3),
                                flower => random-word(2)}
        );

my %dfData1 =
        random-tabular-dataset(12,
                <misnomer tank flower puma>,
                generators => { misnomer => -> $x { (rand xx $x).Array },
                                tank => random-pet-name(3),
                                flower => random-word(2)}):row-names;


say '#============================================================';
say '# Array of hashes';
say '#============================================================';

say to-pretty-table(@dfData0);
my %res = summarize-at(@dfData0, <misnomer tank>, [&min, &max, &elems]);
say to-pretty-table([%res,]);


say '#============================================================';
say '# Hash of hashes';
say '#============================================================';

say to-pretty-table(%dfData1);
say select-columns(%dfData1, <misnomer tank flower>).raku;

%res = summarize-at(%dfData1, <misnomer tank flower>, [&min, &max, &elems]);
say %res;
say to-pretty-table([%res,]);


say '#============================================================';
say '# Over grouped array of hashes';
say '#============================================================';

my %dfData2 = group-by(@dfData0, <tank flower> );
%dfData2.map({ say $_.key, "=>\n", (to-pretty-table($_.value)) });

my %grRes = %dfData2.map({ $_.key => summarize-at($_.value, <misnomer  puma>, (&elems, &min)) });
say to-pretty-table(%grRes);


say '#============================================================';
say '# Over grouped hash of hashes';
say '#============================================================';

my %dfData3 = group-by(%dfData1, <tank> );
say %dfData3;
%dfData3.map({ say $_.key, "=>\n", (to-pretty-table($_.value)) });

my %grRes2 = %dfData3.map({ $_.key => summarize-at($_.value, <misnomer flower puma>, &min) });
say to-pretty-table(%grRes2);