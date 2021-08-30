use Test;

use lib './lib';
use lib '.';

use Text::CSV;
use Data::Reshapers;

my $csv = Text::CSV.new;
my $fileName = $*CWD.Str ~ "/resources/dfTitanic.csv";

my @tblHeaders = $csv.csv(in => $fileName, headers => "auto");
my Hash @array-of-hashes = @tblHeaders;

my @tblNoHeaders = $csv.csv(in => $fileName, headers => "none");
my Array @array-of-arrays = @tblNoHeaders;

#`(
The tests below can be derived / verified with the following Mathematica code:

```mathematica
dfTitanic = ResourceFunction["ImportCSVToDataset"]["https://raw.githubusercontent.com/antononcube/MathematicaVsR/master/Data/MathematicaVsR-Data-Titanic.csv"]
ResourceFunction["CrossTabulate"][dfTitanic[[All, {"passengerClass", "passengerSex"}]]]
ResourceFunction["CrossTabulate"][dfTitanic[[All, {"passengerClass", "passengerSex", "passengerAge"}]]]
```
)

plan 15;

## 1
ok $fileName.IO.e;

## 2
ok @array-of-hashes.isa(Array[Hash]);

## 3
ok @array-of-arrays.isa(Array[Array]);

##-----------------------------------------------------------
## Counts for two columns
##-----------------------------------------------------------

## 4
my Hash %res0 = "1st" => %(:female(144), :male(179)), "2nd" => %(:female(106), :male(171)), "3rd" => %(:male(493), :female(216));

## 5
my Hash %res1;
lives-ok
        { %res1 = cross-tabulate(@tblHeaders, 'passengerClass', 'passengerSex') },
        "cross tabulation of array of hashes";

## 6
my Hash %res2;
lives-ok
        { %res2 = cross-tabulate(@tblNoHeaders, 1, 3) },
        "cross tabulation of array of arrays";


## 7
is
        (%res0.isa(Hash[Hash]), %res1.isa(Hash[Hash]), %res2.isa(Hash[Hash])),
        (True, True, True),
        "cross tabulation expected result shapes";

## 8
my @two-keys = %res0.keys X %res0<1st>.keys;
ok
        [&&] (do for @two-keys -> $p { %res0{$p[0]}{$p[1]} == %res1{$p[0]}{$p[1]} }),
                "cross tabulation expected equivalence for array of hashes";

## 9
ok
        [&&] (do for @two-keys -> $p { %res0{$p[0]}{$p[1]} == %res2{$p[0]}{$p[1]} }),
                "cross tabulation expected equivalence for array of arrays";

##-----------------------------------------------------------
## Sums for three columns
##-----------------------------------------------------------

## 10
my Hash %res30 = "1st" => %(:female(144), :male(179)), "2nd" => %(:female(106), :male(171)), "3rd" => %(:male(493), :female(216));

## 11
my Hash %res31;
lives-ok
        { %res31 = cross-tabulate(@tblHeaders, 'passengerClass', 'passengerSex', 'passengerAge') },
        "cross tabulation sum of array of hashes";

## 12
my Hash %res32;
lives-ok
        { %res32 = cross-tabulate(@tblNoHeaders, 1, 3, 2) },
        "cross tabulation sum of array of arrays";


## 13
is
        (%res30.isa(Hash[Hash]), %res31.isa(Hash[Hash]), %res32.isa(Hash[Hash])),
        (True, True, True),
        "cross tabulation sum expected result shapes";

## 14
ok
        [&&] (do for @two-keys -> $p { %res0{$p[0]}{$p[1]} == %res1{$p[0]}{$p[1]} }),
                "cross tabulation sum expected equivalence for array of hashes";

## 15
ok
        [&&] (do for @two-keys -> $p { %res0{$p[0]}{$p[1]} == %res2{$p[0]}{$p[1]} }),
                "cross tabulation sum expected equivalence for array of arrays";

done-testing;
