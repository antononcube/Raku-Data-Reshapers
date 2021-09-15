# Raku Data::Reshapers

This Raku package has data reshaping functions for different data structures that are 
coercible to full arrays.

The supported data structures are:
  - Positional-of-hashes
  - Positional-of-arrays
 
The three data reshaping provided by the package over those data structures are:

- Cross tabulation, `cross-tabulate`
- Long format conversion, `to-long-format`
- Wide format conversion, `to-wide-format`

Those three operations are fundamental in data wrangling and data analysis; 
see [AA1, Wk1, Wk2, AAv1-AAv2].


------

## Usage examples

### Cross tabulation

Making contingency tables -- or cross tabulation -- is a fundamental statistics and data analysis operation,
[Wk1, AA1]. 

Here is an example using the 
[Titanic](https://en.wikipedia.org/wiki/Titanic) 
dataset (that is provided by this package through the function `get-titanic-dataset`):

```perl6
use Data::Reshapers;

my @tbl = get-titanic-dataset();
say cross-tabulate( @tbl, 'passengerSex', 'passengerClass');

# {female => {1st => 144, 2nd => 106, 3rd => 216}, male => {1st => 179, 2nd => 171, 3rd => 493}}
```

### Long format

Conversion to long format allows column names to be treated as data.

(More precisely, when converting to long format specified column names of a tabular dataset become values
in a dedicated column, e.g. "Variable" in the long format.)

```perl6
use Data::Reshapers;

my @tbl1 = @tbl.roll(5);
.say for @tbl1;

.say for to-long-format( @tbl1 );

my @lfRes1 = to-long-format( @tbl1, 'id', [], variablesTo => "VAR", valuesTo => "VAL2" );
.say for @lfRes1;
```

### Wide format

Here we transform the long format result `@lfRes1` above into wide format -- 
the result has the same records as the `@tbl1`:

```perl6
use Data::Reshapers;

.say for to-wide-format( @lfRes1, 'id', "VAR", "VAL2" );
```

### Unified interface

There is a unified interface to all package functions through the function `data-reshape`:

```perl6
use Data::Reshapers;
my @tbl = get-titanic-dataset();
say data-reshape('cross-tabulate', @tbl, 'passengerSex', 'passengerClass');
my @lfRes = data-reshape('to-long-format', @tbl);
my @wfRes = data-reshape('to-wide-format', @lfRes, 'AutomaticKey', 'Variable', 'Value'); 
```

------

## TODO

1. [X] Simpler more convenient interface.

   - ~~Currently, a user have to specify four different namespaces
     in order to be able to use all package functions.~~
    
2. [ ] More extensive long format tests.

3. [ ] More extensive wide format tests.

4. [ ] Implement verifications for
   
    - [X] Positional-of-hashes
      
    - [X] Positional-of-arrays
    
    - [ ] Positional-of-hashes, each record of which has:
      
       - [ ] Same keys 
       - [ ] Same type of values of corresponding keys
      
    - [ ] Positional-of-arrays, each record of which has:
    
       - [ ] Same length
       - [ ] Same type of values of corresponding elements

5. [ ] Document examples using 
   [Pretty::Table](https://gitlab.com/uzluisf/raku-pretty-table) 
   and/or 
   [Text::Table::Simple](https://github.com/ugexe/Perl6-Text--Table--Simple).

------

## References

### Articles

[AA1] Anton Antonov
["Contingency tables creation examples"](https://mathematicaforprediction.wordpress.com/2016/10/04/contingency-tables-creation-examples/), 
(2016), 
[MathematicaForPrediction at WordPress](https://mathematicaforprediction.wordpress.com).

[Wk1] Wikipedia entry, [Contingency table](https://en.wikipedia.org/wiki/Contingency_table).

[Wk2] Wikipedia entry, [Wide and narrow data](https://en.wikipedia.org/wiki/Wide_and_narrow_data).

### Functions, repositories

[AAf1] Anton Antonov,
[CrossTabulate](https://resources.wolframcloud.com/FunctionRepository/resources/CrossTabulate),
(2019),
[Wolfram Function Repository](https://resources.wolframcloud.com/FunctionRepository).

[AAf2] Anton Antonov,
[LongFormDataset](https://resources.wolframcloud.com/FunctionRepository/resources/LongFormDataset),
(2020),
[Wolfram Function Repository](https://resources.wolframcloud.com/FunctionRepository).

[AAf3] Anton Antonov,
[WideFormDataset](https://resources.wolframcloud.com/FunctionRepository/resources/WideFormDataset),
(2021),
[Wolfram Function Repository](https://resources.wolframcloud.com/FunctionRepository).

[AAf4] Anton Antonov,
[RecordsSummary](https://resources.wolframcloud.com/FunctionRepository/resources/RecordsSummary),
(2019),
[Wolfram Function Repository](https://resources.wolframcloud.com/FunctionRepository).


### Videos

[AAv1] Anton Antonov,
["Multi-language Data-Wrangling Conversational Agent"](https://www.youtube.com/watch?v=pQk5jwoMSxs),
(2020),
[YouTube channel of Wolfram Research, Inc.](https://www.youtube.com/channel/UCJekgf6k62CQHdENWf2NgAQ).
(Wolfram Technology Conference 2020 presentation.)

[AAv2] Anton Antonov,
["Data Transformation Workflows with Anton Antonov, Session #1"](https://www.youtube.com/watch?v=pQk5jwoMSxs),
(2020),
[YouTube channel of Wolfram Research, Inc.](https://www.youtube.com/channel/UCJekgf6k62CQHdENWf2NgAQ).

[AAv3] Anton Antonov,
["Data Transformation Workflows with Anton Antonov, Session #2"](https://www.youtube.com/watch?v=DWGgFsaEOsU),
(2020),
[YouTube channel of Wolfram Research, Inc.](https://www.youtube.com/channel/UCJekgf6k62CQHdENWf2NgAQ).
