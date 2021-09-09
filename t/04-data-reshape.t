use Test;

use lib './lib';
use lib '.';

use Data::Reshapers;

my @tblHeaders = Data::Reshapers::get-titanic-dataset(headers => 'auto');
my Hash @array-of-hashes = @tblHeaders;

my @tblNoHeaders = Data::Reshapers::get-titanic-dataset(headers => 'none');
my Array @array-of-arrays = @tblNoHeaders;

#`(
The tests below can be derived / verified with the following Mathematica code:

TBD...

)

plan 4;

## 1
ok @tblHeaders.isa(Array) and
        @array-of-hashes.isa(Array[Hash]) and
        @array-of-arrays.isa(Array[Array]);

## 2
my @lfRes1 = data-reshape( 'to-long-format', @array-of-hashes);

is-deeply
        @lfRes1[0].keys.sort,
        <AutomaticKey Variable Value>.sort,
        'long-format conversion expected keys, defaults';

## 3
my @lfRes2 = data-reshape( 'to-long-format', @array-of-hashes, [], []);

is-deeply
        @lfRes2[0].keys.sort,
        <AutomaticKey Variable Value>.sort,
        'long-format conversion expected keys, defaults';

## 4
my @wfRes1 = data-reshape( 'to-wide-format', @lfRes1, "AutomaticKey", "Variable", "Value");

is-deeply
        (@wfRes1.elems, @wfRes1[0].elems),
        (@array-of-hashes.elems, @array-of-hashes[0].elems+1),
        'wide-format conversion expected size, defaults';

done-testing;
