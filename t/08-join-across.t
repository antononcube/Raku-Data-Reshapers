use Test;

use Data::Reshapers;

# The test data was generated with the package Data::Generators.
# my @a = random-tabular-dataset(6, <A B C>, generators=>['gala'.comb.List, 'sin'.comb.List, [3,4,5]]);
# my @b = random-tabular-dataset(8, <A D E>, generators=>['lalab'.comb.List, 'rick'.comb.List, [13,14,15]]);
# say to-pretty-table(@a);
# say to-pretty-table(@b);

my @a = [{ :A("g"), :B("n"), :C(4) },
         { :A("a"), :B("i"), :C(4) },
         { :A("l"), :B("n"), :C(3) },
         { :A("g"), :B("i"), :C(3) },
         { :A("a"), :B("n"), :C(5) },
         { :A("a"), :B("n"), :C(5) }];

my @b = [{ :A("a"), :D("k"), :E(15) },
         { :A("b"), :D("k"), :E(13) },
         { :A("a"), :D("r"), :E(15) },
         { :A("l"), :D("k"), :E(13) },
         { :A("a"), :D("i"), :E(13) },
         { :A("l"), :D("k"), :E(15) },
         { :A("a"), :D("i"), :E(13) },
         { :A("l"), :D("i"), :E(13) }];

plan 7;

## 1
is-deeply join-across(@a, @b, 'A', join-spec => 'Inner').sort,
        [{ :A("l"), :B("n"), :C(3), :D("i"), :E(13) },
         { :A("a"), :B("n"), :C(5), :D("i"), :E(13) }].sort,
        'join across inner';

## 2
is-deeply join-across(@a, @b, 'A', join-spec => 'Left', :!fill).sort,
        [{ :A("l"), :B("n"), :C(3), :D("i"), :E(13) },
         { :A("g"), :B("i"), :C(3) },
         { :A("a"), :B("n"), :C(5), :D("i"), :E(13) }].sort,
        'join across left, no fill';


## 3
is-deeply join-across(@a, @b, 'A', join-spec => 'Left', :fill, missing-value=>'Whatever').sort,
        [{ :A("l"), :B("n"), :C(3), :D("i"), :E(13) },
         { :A("g"), :B("i"), :C(3), :D('Whatever'), :E('Whatever') },
         { :A("a"), :B("n"), :C(5), :D("i"), :E(13) }].sort,
        'join across left, with fill';


## 4
is-deeply join-across(@a, @b, 'A', join-spec => 'Right', :!fill).sort,
        [{ :A("a"), :B("n"), :C(5), :D("i"), :E(13) },
         { :A("l"), :B("n"), :C(3), :D("i"), :E(13) },
         { :A("b"), :D("k"), :E(13) }].sort,
        'join across inner, with no fill';


## 5
is-deeply join-across(@a, @b, 'A', join-spec => 'Right', :fill, missing-value=>'Whatever').sort,
        [{ :A("a"), :B("n"), :C(5), :D("i"), :E(13) },
         { :A("l"), :B("n"), :C(3), :D("i"), :E(13) },
         { :A("b"), :B('Whatever'), :C('Whatever'), :D("k"), :E(13) }].sort,
        'join across inner, with fill';


## 6
is-deeply join-across(@a, @b, 'A', join-spec => 'Outer', :!fill).sort,
        [{ :A("a"), :B("n"), :C(5), :D("i"), :E(13) },
         { :A("g"), :B("i"), :C(3) },
         { :A("b"), :D("k"), :E(13) },
         { :A("l"), :B("n"), :C(3), :D("i"), :E(13) }].sort,
        'join across inner, with fill';

## 7
is-deeply join-across(@a, @b, 'A', join-spec => 'Outer', :fill, missing-value=>'Whatever').sort,
        [{ :A("a"), :B("n"), :C(5), :D("i"), :E(13) },
         { :A("g"), :B("i"), :C(3), :D('Whatever'), :E('Whatever') },
         { :A("b"), :B('Whatever'), :C('Whatever'), :D("k"), :E(13) },
         { :A("l"), :B("n"), :C(3), :D("i"), :E(13) }].sort,
        'join across inner, with fill';

done-testing;
