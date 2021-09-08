use Test;

use lib './lib';
use lib '.';

use Data::Reshapers;
use Data::Reshapers::ToLongFormat;

my @tblHeaders = Data::Reshapers::get-titanic-dataset(headers => 'auto');
my Hash @array-of-hashes = @tblHeaders;

my @tblNoHeaders = Data::Reshapers::get-titanic-dataset(headers => 'none');
my Array @array-of-arrays = @tblNoHeaders;

#`(
The tests below can be derived / verified with the following Mathematica code:

```mathematica
dfTitanic = ResourceFunction["ImportCSVToDataset"]["https://raw.githubusercontent.com/antononcube/MathematicaVsR/master/Data/MathematicaVsR-Data-Titanic.csv"]
ResourceFunction["LongFormDataset"][dfTitanic, "VariablesTo"->"VAR", "ValuesTo"->"VAL2"]
```
)

plan 11;

## 1
ok @tblHeaders.isa(Array);

## 2
ok @array-of-hashes.isa(Array[Hash]);

## 3
ok @array-of-arrays.isa(Array[Array]);

##-----------------------------------------------------------
## 4
my @lfRes1 = to-long-format( @array-of-hashes, [], []);
is-deeply
        @lfRes1[0].keys.sort,
        <AutomaticKey Variable Value>.sort,
        'long-format conversion expected keys, defaults';

## 5
is-deeply
        @lfRes1.elems,
        @array-of-hashes.elems * @array-of-hashes[0].elems,
        'long-format conversion expected size, defaults';

##-----------------------------------------------------------
## 6
my @lfRes2 = to-long-format( @array-of-hashes, [], [], variablesTo => "VAR", valuesTo => "VAL2" );
is-deeply
        @lfRes2[0].keys.sort,
        <AutomaticKey VAR VAL2>.sort,
        'long-format conversion expected keys, specified variablesTo and valuesTo';

## 7
is-deeply
        @lfRes2.elems,
        @array-of-hashes.elems * @array-of-hashes[0].elems,
        'long-format conversion expected size, specified variablesTo and valuesTo';

##-----------------------------------------------------------
## 8
my @lfRes3 = to-long-format( @array-of-hashes, 'id', [], variablesTo => "VAR", valuesTo => "VAL2" );
is-deeply
        @lfRes3[0].keys.sort,
        <id VAR VAL2>.sort,
        'long-format conversion expected keys, specified id, variablesTo and valuesTo';

## 9
is-deeply
        @lfRes3.elems,
        @array-of-hashes.elems * (@array-of-hashes[0].elems - 1),
        'long-format conversion expected size, specified id, variablesTo and valuesTo';

##-----------------------------------------------------------
## 10
my @lfRes4 = to-long-format( @array-of-hashes, 'id', <passengerSex passengerClass> );
is-deeply
        @lfRes4[0].keys.sort,
        <id Variable Value>.sort,
        'long-format conversion expected keys, specified id and variables';

## 11
is-deeply
        @lfRes4.elems,
        @array-of-hashes.elems * <passengerSex passengerClass>.elems,
        'long-format conversion expected size, specified id and variables';

done-testing;
