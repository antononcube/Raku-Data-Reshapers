use Test;

use lib './lib';
use lib '.';

use Text::CSV;
use Data::Reshapers::CrossTabulate;

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
dfTitanic[GroupBy[#passengerClass &], Length]
dfTitanic[GroupBy[#passengerClass &], Total[#passengerAge & /@ #] &]
```
)

plan 23;

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
my Hash %res0 = "1st" => %(:female(144), :male(179)), "2nd" => %(:female(106), :male(171)), "3rd" => %(:male(493),
                                                                                                       :female(216));
ok
        %res0.isa(Hash[Hash]),
        "expected result for counts";

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
my Hash %res30 = "1st" => %(:female(144), :male(179)), "2nd" => %(:female(106), :male(171)), "3rd" => %(:male(493),
                                                                                                        :female(216));
ok
        %res30.isa(Hash[Hash]),
        "expected result for sums";

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
        [&&] (do for @two-keys -> $p { %res30{$p[0]}{$p[1]} == %res31{$p[0]}{$p[1]} }),
                "cross tabulation sum expected equivalence for array of hashes";

## 15
ok
        [&&] (do for @two-keys -> $p { %res30{$p[0]}{$p[1]} == %res32{$p[0]}{$p[1]} }),
                "cross tabulation sum expected equivalence for array of arrays";

##-----------------------------------------------------------
## Counts for one column
##-----------------------------------------------------------

## 16
my Int %res40 = "1st" => 323, "2nd" => 277, "3rd" => 709;
ok
        %res40.isa(Hash[Int]),
        "expected result for counts with one column";

## 17
my Int %res41;
lives-ok
        { %res41 = cross-tabulate(@tblHeaders, 'passengerClass') },
        "one-column-cross-tabulation counts over array of hashes";

## 18
my Int %res42;
lives-ok
        { %res42 = cross-tabulate(@tblNoHeaders, 1) },
        "one-column-cross-tabulation counts over array of arrays";

## 19
ok
        [&&] (do for %res40.keys -> $k { %res40{$k} == %res41{$k} }),
                "one-column-cross-tabulation counts expected equivalence for array of hashes";

## 20
ok
        [&&] (do for %res40.keys -> $k { %res40{$k} == %res42{$k} }),
                "one-column-cross-tabulation counts expected equivalence for array of arrays";

##-----------------------------------------------------------
## Sums for one column
##-----------------------------------------------------------

## 21
my Int %res50 = "1st" => 11131, "2nd" => 7574, "3rd" => 12122;
ok
        %res50.isa(Hash[Int]),
        "expected result for sums with one column";

## 22
my Int %res51;
lives-ok
        { %res51 = cross-tabulate(@tblHeaders, 'passengerClass', '', 'passengerAge') },
        "one-column-cross-tabulation sums over array of hashes";

## 23
ok
        [&&] (do for %res50.keys -> $k { %res50{$k} == %res51{$k} }),
                "one-column-cross-tabulation sums expected equivalence for array of hashes";

done-testing;
