use Test;

use lib './lib';
use lib '.';

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
         ["86",   "1st", "40", "female", "survived"],
         ["1014", "3rd", "-1", "female", "died"],
         ["845",  "3rd", "30", "male",   "died"],
         ["103",  "1st", "20", "female", "survived"],
         ["523",  "2nd", "40", "male",   "died"]];

my Array @array-of-arrays2 =
        Array[Array].new(
                $["1175", "1082", "86", "1014", "845", "103", "523"],
                $["3rd", "3rd", "1st", "3rd", "3rd", "1st", "2nd"],
                $["-1", "-1", "40", "-1", "30", "20", "40"],
                $["female", "female", "female", "female", "male", "female", "male"],
                $["died", "survived", "survived", "died", "died", "survived", "died"]);


plan 4;

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

done-testing;
