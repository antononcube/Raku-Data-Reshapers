use Test;

use lib './lib';
use lib '.';

use Data::Reshapers;

# The test data was generated with the package Data::Generators.
# my @dfData0 = random-tabular-dataset(4, <alpha beta gamma delta>, generators=>[ -> $x { (rand xx $x).Array }, &random-pet-name]);
# my %dfData1 = random-tabular-dataset(4, <alpha beta gamma delta>, generators=>[ -> $x { (rand xx $x).Array }, &random-pet-name], :row-names);

my @dfData0 = [{ :alpha(0.1162641854786215e0), :beta("Millie"), :delta("Guinness"), :gamma(0.3124665964634822e0) },
               { :alpha(0.5276046799428872e0), :beta("Professor Nibblesworth"), :delta("Darcy"), :gamma(0.7355073717255032e0) },
               { :alpha(0.49617051391358613e0), :beta("Patches"), :delta("Millie"), :gamma(0.499054180911335e0) },
               { :alpha(0.17019649648531154e0), :beta("Guinness"), :delta("Guinness"), :gamma(0.6381347270165434e0) }];

my %dfData1 = "0" => ${ :alpha(0.9038461749723564e0), :beta("Tacoma"), :delta("Katphryn Vera Rose"), :gamma(0.9183769432021661e0) },
              "1" => ${ :alpha(0.027574831889919604e0), :beta("Tacoma"), :delta("Tela"), :gamma(0.7438756520148029e0) },
              "2" => ${ :alpha(0.6867433585468795e0), :beta("Gusty"), :delta("Moufette"), :gamma(0.65074069370148e0) },
              "3" => ${ :alpha(0.8153474825814797e0), :beta("Tacoma"), :delta("Katphryn Vera Rose"), :gamma(0.5623954124920828e0) };


plan 15;

## 1
is-deeply select-columns(@dfData0, <delta beta>)>>.keys>>.Array.unique(:as({ $_.sort.Array }):with(&[eqv]))>>.sort>>.List,
        (<beta delta>,),
        "Array of hashes selection";

## 2
is-deeply select-columns(%dfData1.pairs, <delta beta>)>>.value>>.keys>>.Array.unique(:as({ $_.sort.Array }):with(&[eqv]))>>.sort>>.List,
        (<beta delta>,),
        "Array of key-to-hash pairs selection";


## 3
is-deeply select-columns(%dfData1, <delta beta>).values>>.keys>>.Array.unique(:as({ $_.sort.Array }):with(&[eqv]))>>.sort>>.List,
        (<beta delta>,),
        "Hash of hashes selection";

## 4
# Wow, that is a very complicated line to just find the unique lists.
# .Array and .List are needed because all other operations produce Seq objects.
is-deeply rename-columns(@dfData0, { delta => 'ura', 'beta' => 'B' })>>.keys>>.Array.unique(:as({ $_.sort.Array }):with(&[eqv]))>>.sort>>.List,
        (<B alpha gamma ura>,),
        "Array of hashes renaming";


## 5
is-deeply rename-columns(%dfData1, { delta => 'ura', 'beta' => 'B' }).values>>.keys>>.Array.unique(:as({ $_.sort.Array }):with(&[eqv]))>>.sort>>.List,
        (<B alpha gamma ura>,),
        "Hash of hashes renaming";

## 6
is-deeply select-columns(@dfData0, { delta => 'ura', 'beta' => 'B' })>>.keys>>.Array.unique(:as({ $_.sort.Array }):with(&[eqv]))>>.sort>>.List,
        (<B ura>,),
        "Array of hashes renaming selection";


## 7
is-deeply select-columns(%dfData1, { delta => 'ura', 'beta' => 'B' }).values>>.keys>>.Array.unique(:as({ $_.sort.Array }):with(&[eqv]))>>.sort>>.List,
        (<B ura>,),
        "Hash of hashes renaming selection";

## 8
my $res7 = [(&)] select-columns(@dfData0, 'beta')>>.Set;

is-deeply $res7, Set(<beta>),
        "Array of hashes single column selection";

## 9
my $res8 = [(&)] select-columns(%dfData1, 'beta').values>>.Set;

is-deeply $res8, Set(<beta>),
        "Hash of hashes single column selection";

## 10
my $res9 = [(&)] rename-columns(@dfData0, 'beta' => 'CIGAR')>>.Set;

is-deeply $res9, Set(<alpha CIGAR gamma delta>),
        "Array of hashes single pair ranaming.";

## 11
my $res10 = [(&)] rename-columns(%dfData1, 'beta' => 'CIGAR').values>>.Set;

is-deeply $res10, Set(<alpha CIGAR gamma delta>),
        "Hash of hashes single pair ranaming.";

## 12
my $res11 = [(&)] delete-columns(@dfData0, 'beta')>>.Set;

is-deeply $res11, Set(<alpha gamma delta>),
        "Array of hashes single var delection.";

## 13
my $res12 = [(&)] delete-columns(%dfData1, 'beta').values>>.Set;

is-deeply $res12, Set(<alpha gamma delta>),
        "Hash of hashes single var deletion.";

## 14
my $res13 = [(&)] delete-columns(%dfData1, <delta beta>).values>>.Set;

is-deeply $res13, Set(<alpha gamma>),
        "Hash of hashes vars deletion.";

## 15
my $res14 = [(&)] delete-columns(%dfData1, <delta beta>).values>>.Set;

is-deeply $res14, Set(<alpha gamma>),
        "Hash of hashes vars deletion.";

done-testing;
