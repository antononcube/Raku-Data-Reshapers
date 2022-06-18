use Test;

use Data::Reshapers;

#my %hash-of-hashes = cross-tabulate( get-titanic-dataset(), 'passengerSex', 'passengerClass');
my %hash-of-hashes =
        female => { died => 127, survived => 339 }, male => { died => 682, survived => 161 };

my %hash-of-hashes2 =
        died => { female => 127, male => 682 }, survived => { female => 339, male => 161 };

my Hash @array-of-hashes =
        [{ :id("745"), :passengerAge("20"), :passengerClass("3rd"), :passengerSex("male"), :passengerSurvival("died") },
         { :id("1092"), :passengerAge("20"), :passengerClass("3rd"), :passengerSex("female"), :passengerSurvival("died") },
         { :id("658"), :passengerAge("0"), :passengerClass("3rd"), :passengerSex("female"), :passengerSurvival("survived") }];

my Pair @array-of-key-array-pairs =
        [:id($["745", "1092", "658"]),
         :passengerAge($["20", "20", "0"]),
         :passengerClass($["3rd", "3rd", "3rd"]),
         :passengerSex($["male", "female", "female"]),
         :passengerSurvival($["died", "died", "survived"])];


my Array @array-of-arrays =
        [["1175", "3rd", "-1", "female", "died"],
         ["1082", "3rd", "-1", "female", "survived"],
         ["86", "1st", "40", "female", "survived"],
         ["1014", "3rd", "-1", "female", "died"],
         ["845", "3rd", "30", "male", "died"],
         ["103", "1st", "20", "female", "survived"],
         ["523", "2nd", "40", "male", "died"]];

my Array @array-of-arrays2 =
        Array[Array].new(
                $["1175", "1082", "86", "1014", "845", "103", "523"],
                $["3rd", "3rd", "1st", "3rd", "3rd", "1st", "2nd"],
                $["-1", "-1", "40", "-1", "30", "20", "40"],
                $["female", "female", "female", "female", "male", "female", "male"],
                $["died", "survived", "survived", "died", "died", "survived", "died"]);

my @dfRand = ["2" => ${ :drink(121.67239295221576e0), :refinance(111.49589770601989e0), :uncompromisingly(112.83057932039914e0) },
              "1" => ${ :drink(140.0346028991027e0), :refinance(99.8238528322897e0), :uncompromisingly(86.9574096817264e0) },
              "0" => ${ :drink(125.29827601833546e0), :refinance(101.04520165281197e0), :uncompromisingly(91.49572496103593e0) },
              "4" => ${ :drink(124.73006527768604e0), :refinance(74.26748488483263e0), :uncompromisingly(150.10090828356613e0) },
              "3" => ${ :drink(102.0971638701688e0), :refinance(75.86794386663075e0), :uncompromisingly(114.90831504979715e0) }];

plan 5;

## 1
is-deeply transpose(%hash-of-hashes),
        %hash-of-hashes2,
        'transpose of hash-of-hashes';

## 2
is-deeply transpose(transpose(%hash-of-hashes)),
        %hash-of-hashes,
        'transpose of or transpose hash-of-arrays';

## 3
is-deeply transpose(@array-of-hashes).List.sort,
        @array-of-key-array-pairs.List.sort,
        'transpose of array-of-hashes';

## 4
is-deeply transpose(transpose(@array-of-hashes)),
        @array-of-hashes,
        'transpose of transpose of array-of-hashes';

## 5
ok transpose(@dfRand),
        'transpose of array of key-hash pairs';

done-testing;
