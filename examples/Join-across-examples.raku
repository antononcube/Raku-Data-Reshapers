#!/usr/bin/env perl6

# use lib <. lib>

use Data::Reshapers;
use Data::Generators;

#============================================================
# Data generation
#============================================================

my @a = random-tabular-dataset(4, <A B C>, generators => ['ab'.comb.List, 'er'.comb.List, [3, 4, 5]]);
my @b = random-tabular-dataset(6, <A B E>, generators => ['ac'.comb.List, 'em'.comb.List, [13, 14, 15]]);
say to-pretty-table(@a);
say to-pretty-table(@b);

say '#============================================================';
say '# Join with one key';
say '#============================================================';

my $res = join-across(@a, @b, 'A', join-spec => 'Inner').sort;
say to-pretty-table($res);

say '#============================================================';
say '# Join with many keys';
say '#============================================================';

my $res2 = join-across(@a, @b, <A B>, join-spec => 'Inner').sort;
say to-pretty-table($res2);