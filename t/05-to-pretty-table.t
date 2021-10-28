use Test;

use lib './lib';
use lib '.';

use Data::Reshapers;

my @tblHeaders = Data::Reshapers::get-titanic-dataset(headers => 'auto');
my Hash @array-of-hashes = @tblHeaders;

my @tblNoHeaders = Data::Reshapers::get-titanic-dataset(headers => 'none');
my Array @array-of-arrays = @tblNoHeaders;

my %hash-of-hashes = cross-tabulate(@array-of-hashes, 'passengerSex', 'passengerClass');

my %hash-of-arrays =
    id => [372, 1111, 995],
    passengerAge => [40, 30, -1],
    passengerClass => <2nd 3rd 3rd>,
    passengerSex => <female male male>,
    passengerSurvival => <survived died died>;

my Pair @array-of-key-array-pairs =
        [:id($["745", "1092", "658"]),
         :passengerAge($["20", "20", "0"]),
         :passengerClass($["3rd", "3rd", "3rd"]),
         :passengerSex($["male", "female", "female"]),
         :passengerSurvival($["died", "died", "survived"])];

my @dfRand = ["2" => ${ :drink(121.67239295221576e0), :refinance(111.49589770601989e0), :uncompromisingly(112.83057932039914e0) },
              "1" => ${ :drink(140.0346028991027e0), :refinance(99.8238528322897e0), :uncompromisingly(86.9574096817264e0) },
              "0" => ${ :drink(125.29827601833546e0), :refinance(101.04520165281197e0), :uncompromisingly(91.49572496103593e0) },
              "4" => ${ :drink(124.73006527768604e0), :refinance(74.26748488483263e0), :uncompromisingly(150.10090828356613e0) },
              "3" => ${ :drink(102.0971638701688e0), :refinance(75.86794386663075e0), :uncompromisingly(114.90831504979715e0) }];

plan 12;

## 1
ok @tblHeaders.isa(Array) and
        @array-of-hashes.isa(Array[Hash]) and
        @array-of-arrays.isa(Array[Array]) and
        %hash-of-hashes.isa(Hash[Hash]);

## 2
ok to-pretty-table(%hash-of-hashes), 'pretty table of hash-of-hashes';

## 3
ok to-pretty-table(%hash-of-arrays), 'pretty table of hash-of-arrays';

## 4
ok to-pretty-table(@array-of-hashes.roll(5)), 'pretty table of array-of-hashes';

## 5
ok to-pretty-table(@array-of-arrays.roll(5)), 'pretty table of array-of-arrays';

## 6
ok to-pretty-table( [[4, 3], [1, 3], [9, 3]], title => "Data test 1");

## 7
ok to-pretty-table( [<4 3 6>, <1 3 7>, <9 3 232>], title => "Data test 2");

## 8
ok to-pretty-table( (<4 3 6>, <1 3 7>, <9 3 232>), title => "Data test 3");

## 9
ok to-pretty-table( @array-of-key-array-pairs, title => "Array of key-array pairs");

## 10
fails-like { to-pretty-table((4, 3, 3), title => "Data wrong 1") },
        X::AdHoc,
        :message(/'If the first argument is an array then it is expected'/),
        'data wrong 1';

## 11
fails-like { to-pretty-table([[1,2,2], [3,3,2], [3,2]], title => "Data wrong 2") },
        X::AdHoc,
        :message(/'If the first argument is an array then it is expected'/),
        'data wrong 2';

## 12
ok to-pretty-table(@dfRand),
        'pretty table of array of key-hash pairs';

done-testing;
