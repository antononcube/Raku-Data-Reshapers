use Test;

use lib './lib';
use lib '.';

use Data::Reshapers;
use Data::Reshapers::ToLongFormat;
use Data::Reshapers::ToWideFormat;

my @tblHeaders = Data::Reshapers::get-titanic-dataset(headers => 'auto');
my Hash @array-of-hashes = @tblHeaders;

my @tblNoHeaders = Data::Reshapers::get-titanic-dataset(headers => 'none');
my Array @array-of-arrays = @tblNoHeaders;

#`(
The tests below can be derived / verified with the following Mathematica code:

TBD...

)

plan 2;

## 1
ok @tblHeaders.isa(Array) and
        @array-of-hashes.isa(Array[Hash]) and
        @array-of-arrays.isa(Array[Array]);

##-----------------------------------------------------------
## 2
my @lfRes1 = to-long-format( @array-of-hashes, [], []);
my @wfRes1 = to-wide-format( @lfRes1, "AutomaticKey", "Variable", "Value");

is-deeply
        (@wfRes1.elems, @wfRes1[0].elems),
        (@array-of-hashes.elems, @array-of-hashes[0].elems+1),
        'wide-format conversion expected size, defaults';

done-testing;
