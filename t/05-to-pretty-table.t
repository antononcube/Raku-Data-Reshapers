use Test;

use lib './lib';
use lib '.';

use Data::Reshapers;

my @tblHeaders = Data::Reshapers::get-titanic-dataset(headers => 'auto');
my Hash @array-of-hashes = @tblHeaders;

my @tblNoHeaders = Data::Reshapers::get-titanic-dataset(headers => 'none');
my Array @array-of-arrays = @tblNoHeaders;

my %hash-of-hashes = cross-tabulate(@array-of-hashes, 'passengerSex', 'passengerClass');

plan 9;

## 1
ok @tblHeaders.isa(Array) and
        @array-of-hashes.isa(Array[Hash]) and
        @array-of-arrays.isa(Array[Array]) and
        %hash-of-hashes.isa(Hash[Hash]);

## 2
ok to-pretty-table(%hash-of-hashes), 'pretty table of hash-of-hashes';

## 3
ok to-pretty-table(@array-of-hashes.roll(5)), 'pretty table of array-of-hashes';

## 4
ok to-pretty-table(@array-of-arrays.roll(5)), 'pretty table of array-of-arrays';

## 5
ok to-pretty-table( [[4, 3], [1, 3], [9, 3]], title => "Data test 1");

## 6
ok to-pretty-table( [<4 3 6>, <1 3 7>, <9 3 232>], title => "Data test 2");

## 7
ok to-pretty-table( (<4 3 6>, <1 3 7>, <9 3 232>), title => "Data test 3");

## 8
fails-like { to-pretty-table((4, 3, 3), title => "Data wrong 1") },
        X::AdHoc,
        :message(/'If the first argument is an array then it is expected'/),
        'data wrong 1';

## 9
ok to-pretty-table([[1,2,2], [3,3,2], [3,2]], title => "Data wrong 1"),
        'cannot figure out how check failure here';


done-testing;
