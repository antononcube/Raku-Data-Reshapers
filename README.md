# Raku Data::Reshapers

[![Build Status](https://app.travis-ci.com/antononcube/Raku-Data-Reshapers.svg?branch=main)](https://app.travis-ci.com/github/antononcube/Raku-Data-Reshapers)
[![License: Artistic-2.0](https://img.shields.io/badge/License-Artistic%202.0-0298c3.svg)](https://opensource.org/licenses/Artistic-2.0)

This Raku package has data reshaping functions for different data structures that are 
coercible to full arrays.

The supported data structures are:
  - Positional-of-hashes
  - Positional-of-arrays
 
The four data reshaping provided by the package over those data structures are:

- Cross tabulation, `cross-tabulate`
- Long format conversion, `to-long-format`
- Wide format conversion, `to-wide-format`
- Transpose, `transpose`

The first three operations are fundamental in data wrangling and data analysis; 
see [AA1, Wk1, Wk2, AAv1-AAv2].

(Transposing of tabular data is, of course, also fundamental, but it also can be seen as a
basic functional programming operation.)

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
my $res = cross-tabulate( @tbl, 'passengerSex', 'passengerClass');
say $res;

# {female => {1st => 144, 2nd => 106, 3rd => 216}, male => {1st => 179, 2nd => 171, 3rd => 493}}

say to-pretty-table($res);
# +--------+-----+-----+-----+
# |        | 1st | 2nd | 3rd |
# +--------+-----+-----+-----+
# | female | 144 | 106 | 216 |
# | male   | 179 | 171 | 493 |
# +--------+-----+-----+-----+
```

### Long format

Conversion to long format allows column names to be treated as data.

(More precisely, when converting to long format specified column names of a tabular dataset become values
in a dedicated column, e.g. "Variable" in the long format.)

```perl6
my @tbl1 = @tbl.roll(3);
.say for @tbl1;

.say for to-long-format( @tbl1 );

my @lfRes1 = to-long-format( @tbl1, 'id', [], variablesTo => "VAR", valuesTo => "VAL2" );
.say for @lfRes1;
```

### Wide format

Here we transform the long format result `@lfRes1` above into wide format -- 
the result has the same records as the `@tbl1`:

```perl6
‌‌say to-pretty-table( to-wide-format( @lfRes1, 'id', 'VAR', 'VAL2' ) );

# +-------------------+----------------+--------------+--------------+-----+
# | passengerSurvival | passengerClass | passengerAge | passengerSex |  id |
# +-------------------+----------------+--------------+--------------+-----+
# |        died       |      1st       |      20      |     male     | 308 |
# |        died       |      2nd       |      40      |    female    | 412 |
# |      survived     |      2nd       |      50      |    female    | 441 |
# |        died       |      3rd       |      20      |     male     | 741 |
# |        died       |      3rd       |      -1      |     male     | 932 |
# +-------------------+----------------+--------------+--------------+-----+
```

### Transpose

Using cross tabulation result above:

```perl6
my $tres = transpose( $res );

say to-pretty-table($res, title => "Original");
say to-pretty-table($tres, title => "Transposed");
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

5. [X] Implement "nice tabular visualization" using 
   [Pretty::Table](https://gitlab.com/uzluisf/raku-pretty-table)
   and/or
   [Text::Table::Simple](https://github.com/ugexe/Perl6-Text--Table--Simple).

6. [X] Document examples using pretty tables.

7. [X] Implement transposing operation for
   - [X] hash of hashes
   - [X] hash of arrays
   - [X] array of hashes
   - [X] array of arrays

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
