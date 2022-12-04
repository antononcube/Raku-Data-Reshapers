=begin pod

=head1 Data::Reshapers

C<Data::Reshapers> package has data reshaping functions for
different data structures (full arrays, Red tables, Text::CSV tables.)

=head1 Synopsis

    use Data::Reshapers;

    my @tbl = get-titanic-dataset(headers => "auto");

    my $xtab1 = cross-tabulate(@tbl, 'passengerClass', 'passengerSex');
    my $xtab2 = cross-tabulate(@tbl, 'passengerClass', 'passengerSex', 'passengerAge');

    my @tbl2 = get-titanic-dataset(headers => "none");
    my $xtab3 = cross-tabulate(@tbl, 1, 3);
    my $xtab4 = cross-tabulate(@tbl, 1, 3, 2);

=end pod

unit module Data::Reshapers;

use Text::CSV;
use Data::Reshapers::CrossTabulate;
use Data::Reshapers::ToLongFormat;
use Data::Reshapers::ToWideFormat;
use Data::Reshapers::JoinAcross;
use Data::Reshapers::ToPrettyTable;
use Data::Reshapers::Transpose;
use Data::Reshapers::Predicates;
use Data::Reshapers::TypeSystem;
use Hash::Merge;

#===========================================================

#| Get the Titanic dataset. Returns Positional[Hash] or Positional[Array].
our sub get-titanic-dataset(Str:D :$headers = 'auto', --> Positional) is export {
    my $csv = Text::CSV.new;
    my $fileHandle = %?RESOURCES<dfTitanic.csv>;

    my @tbl = $csv.csv(in => $fileHandle.Str, :$headers);

    return @tbl;
}
#= Ingests the resource file "dfTitanic.csv" of Data::Reshapers.

#===========================================================

#| Get the Lake Mead levels dataset. Returns Positional[Hash] or Positional[Array].
our sub get-lake-mead-levels-dataset(Str:D :$headers = 'auto', --> Positional) is export {
    my $csv = Text::CSV.new;
    my $fileHandle = %?RESOURCES<dfLakeMeadLevels.csv>;

    my @tbl = $csv.csv(in => $fileHandle.Str, :$headers);

    return @tbl;
}
#= Ingests the resource file "dfLakeMeadLevels.csv" of Data::Reshapers.


#===========================================================
our proto cross-tabulate(|) is export {*}

multi cross-tabulate(**@args) {
    Data::Reshapers::CrossTabulate::CrossTabulate(|@args)
}

#===========================================================
our proto to-long-format(|) is export {*}

multi to-long-format(**@args, *%args) {
    Data::Reshapers::ToLongFormat::ToLongFormat(|@args, |%args)
}

#===========================================================
our proto transpose(|) is export {*}

multi transpose(**@args) {
    Data::Reshapers::Transpose::Transpose(|@args)
}

#===========================================================
our proto to-wide-format(|) is export {*}

multi to-wide-format(**@args, *%args) {
    Data::Reshapers::ToWideFormat::ToWideFormat(|@args, |%args)
}

#===========================================================
our proto join-across(|) is export {*}

multi join-across(**@args, *%args) {
    Data::Reshapers::JoinAcross::JoinAcross(|@args, |%args)
}

#===========================================================
our proto data-reshape(|) is export {*}

multi data-reshape('cross-tabulate', **@args) {
    cross-tabulate(|@args)
}

multi data-reshape('to-long-format', **@args, *%args) {
    to-long-format(|@args, |%args)
}

multi data-reshape('to-wide-format', **@args, *%args) {
    to-wide-format(|@args, |%args)
}

multi data-reshape('join-across', **@args,  *%args) {
    join-across(|@args, |%args)
}

multi data-reshape('transpose', **@args) {
    transpose(|@args)
}

#===========================================================
our proto dimensions(|) is export {*}

multi dimensions(%arg -->List) {
    if has-homogeneous-shape(%arg) {
        my $first = %arg.values[0];
        if $first ~~ Pair {
            return (%arg.elems, $first.value.elems)
        }
        return (%arg.elems, $first.elems)
    } else {
        return (%arg.elems)
    }
}

multi dimensions(@arg -->List) {
    if has-homogeneous-shape(@arg) {
        my $first = @arg.values[0];
        if $first ~~ Pair {
            return (@arg.elems, $first.value.elems)
        }
        return (@arg.elems, $first.elems)
    } else {
        return (@arg.elems)
    }
}

#===========================================================
our proto select-columns(|) is export {*}

multi select-columns($data, Whatever, :&chooser = &infix:<(elem)>) {
    return $data;
}

multi select-columns($data, Str $var, :&chooser = &infix:<(elem)>) {
    return select-columns($data, [$var,])
}

multi select-columns(@data, %mapper) {
    return rename-columns(select-columns(@data, %mapper.keys), %mapper)
}

multi select-columns(@data, @vars, :&chooser = &infix:<(elem)>) {
    my %colSet = Set(@vars);
    if is-array-of-hashes(@data) {
        my @res = @data>>.grep({ &chooser($_.key, %colSet) })>>.Hash;
        return @res;
    } elsif is-array-of-key-hash-pairs(@data) {
        # Very similar to the hash-of-hashes case, but since Raku
        # does not support ordered hashes no delegation is used.
        my @res = @data.map({ $_.key => $_.value.pairs.grep({ &chooser($_.key, %colSet) }).Hash });
        return @res;
    } else {
        die "If the first argument is an array then it is expected to be an array of hashes or an array of key-hash pairs."
    }
}

multi select-columns(%data, %mapper) {
    return rename-columns(select-columns(%data, %mapper.keys), %mapper)
}

multi select-columns(%data, @vars, :&chooser = &infix:<(elem)>) {
    if is-hash-of-hashes(%data) {
        my %colSet = Set(@vars);
        my %res = %data.pairs.map({ $_.key => $_.value.pairs.grep({ &chooser($_.key, %colSet) }).Hash })>>.Hash;
        return %res;
    } else {
        die "If the first argument is a hash then it is expected to be a hash of hashes."
    }
}

#===========================================================
our proto rename-columns(|) is export {*}

multi rename-columns(@data, Pair $map) {
    return rename-columns(@data, %($map))
}

multi rename-columns(@data, %mapper) {
    if is-array-of-hashes(@data) {
        my $res = @data>>.map({ %mapper{.key}:exists ?? (%mapper{.key} => .value) !! $_ })>>.Hash;
        return $res;
    } else {
        die "If the first argument is an array then it is expected to be an array of hashes."
    }
}

multi rename-columns(%data, Pair $map) {
    return rename-columns(%data, %($map))
}

multi rename-columns(%data, %mapper) {
    if is-hash-of-hashes(%data) {
        my %res = %data.pairs>>.map({ $_.key => $_.value.map({ %mapper{.key}:exists ?? (%mapper{.key} => .value) !! $_ }).Hash })>>.Hash;
        return %res;
    } else {
        die "If the first argument is a hash then it is expected to be a hash of hashes."
    }
}

#===========================================================
our proto delete-columns(|) is export {*}

multi delete-columns($data, Str $var) {
    return delete-columns($data, [$var,])
}

multi delete-columns(@data, @vars) {
    return select-columns(@data, @vars, chooser => &infix:<∉>)
}

multi delete-columns(%data, Str $var) {
    return delete-columns(%data, [$var,])
}

multi delete-columns(%data, @vars) {
    return select-columns(%data, @vars, chooser => &infix:<∉>)
}

#===========================================================
#| Summarizes given columns (variables) in a given dataset with given functions.
#| C<$data> - Dataset to be summarized; an array of hashes or a hash of hashes.
#| C<$vars> - Variables (column names) to be summarized.
#| C<$func> - A function (callable) or a positional of functions to summarize with.
#| C<:$sep> - A separator to used in the new var-func column names.
our proto summarize-at(|) is export {*}

multi summarize-at($data, $vars, &func, Str :$sep = '.') {
    return summarize-at($data, $vars, [&func,], :$sep)
}

multi summarize-at($data, $vars, @funcs, Str :$sep = '.') {
    if @funcs.all ~~ Callable {

        if is-hash-of-hashes($data) {

            my %res = infix:<X>(transpose(select-columns($data, $vars)),
                    @funcs,
                    :with(-> $c, &f { $c.key ~ $sep ~ &f.name => $c.value.values.Array.&f }));

            return %res;

        } elsif is-array-of-hashes($data) {

            my %res = infix:<X>(transpose(select-columns($data, $vars)),
                    @funcs,
                    :with(-> $c, &f { $c.key ~ $sep ~ &f.name => $c.value.Array.&f }));

            return %res;

        } else {
            die "The first argument is expected to be an array of hashes or a hash of hashes."
        }

    } else {
        die "The third argument is expected to be a list of functions."
    }
}

#===========================================================
#| Group dataset records by values of given variables.
#| C<$data> - Dataset, an array of hashes or a hash of hashes.
#| C<@vars> - Variables to group with.
#| C<:$sep> - A separator to use for the keys corresponding to the groups.
our proto group-by(|) is export {*}

multi group-by($data, Str $var, Str :$sep = '.') {
    return group-by($data, [$var, ], :$sep)
}

multi group-by($data, @vars, Str :$sep = '.') {

    if is-array-of-hashes($data) {

        my %res = $data.classify(-> $row { @vars.map({ $row{$_} }).join($sep) });
        return %res;

    } elsif is-hash-of-hashes($data) {

        my %res = $data.pairs.classify(-> $row { @vars.map({ $row.value{$_} }).join($sep) })>>.Hash;
        return %res;

    } else {
        die "The first argument is expected to be an array of hashes or a hash of hashes."
    }
}

#===========================================================
#| Separates the values of column of a given dataset into other columns using a given separator.
#| C<$data> - Dataset.
#| C<:$from> - Column to separate.
#| C<:@to> - Columns to put the parts in.
#| C<:$sep> - Separator to use. (An argument for C<&split>.)
our proto separate-column(|) is export {*}

multi separate-column($data, Str :$from, :@to, :$sep) {
    return separate-column($data, $from, @to, :$sep);
}

multi separate-column($data, Str $from, @to, :$sep) {
    return $data.map({ merge-hash($_, %( @to Z=> $_{$from}.split($sep):skip-empty)) }).List;
}

#===========================================================
#| Completely flattens a data structure even when sub-lists are wrapped in item containers.
#| C<@data> -- data to be flatten.
#| C<:$max-level> -- max level to flatten to.
our proto flatten(|) is export {*}

# Taken from
# https://stackoverflow.com/q/41648119/
# https://stackoverflow.com/a/41649110/
#multi flatten(+@list) {
#    gather @list.deepmap: *.take
#}

multi flatten($data, $maxLevel = Inf) { flatten($data, max-level => $maxLevel ) }

multi flatten(\leaf, :$max-level = Inf) { leaf }
multi flatten(@list, :$max-level = Inf) {
    if ! ( $max-level ~~ UInt || $max-level === Inf ) {
        die 'The argument max-level is expected to be a non-negative integer or Inf.';
    }
    flatten-rec(@list, $max-level, 0);
}

multi flatten-rec(@list, $maxLevel, UInt $lvl) {
    if $maxLevel > $lvl {
        @list.map: { slip flatten-rec($_, $maxLevel, $lvl+1) }
    } else {
        @list
    }
}

multi flatten-rec(\leaf, $maxLevel, UInt $lvl) { leaf }

multi flatten (%h) {
    %h.keys Z=> %h.values.map({ ($_ ~~ Positional || $_ ~~ Map) ?? flatten($_) !! $_ }).Array
}

#===========================================================
#| C<take-drop(@list, $n)> gives the pair C<($list1, $list2)>,
#| where C<$list1> contains the first C<$n> elements of C<@list> and C<$list2> contains the rest.
#| C<take-drop(@list, @pos)> finds the complement C<@not-pos=((^@list.elems) (-) @pos).keys>
#| and gives the pair C<(@list[@pos], @list[@not-pos])>.
our proto sub take-drop(@data, $spec) is export {*}

multi take-drop(@data, Numeric $ratio where 0 ≤ $ratio < 1) {
    return take-drop(@data, round($ratio * @data.elems));
}

multi take-drop(@data, UInt $n) {
    die "Invalid sequence specification $n for an expression of length {@data.elems}." when $n > @data.elems;
    return (@data[^$n], @data[$n..^@data.elems]);
}

multi take-drop(@data, Seq $s) {
    return take-drop(@data, $s.List);
}

multi take-drop(@data, Range $r) {
    return take-drop(@data, $r.List);
}

multi take-drop(@data, @pos) {
    my @dropTake = ((^@data.elems) (-) @pos).keys;
    return (@data[@pos], @data[@dropTake]);
}

#===========================================================
#| C<stratified-take-drop(@data, $spec, $labels)> applies the function C<take-drop($_, $spec)>
#| over stratified @data groups.
our proto sub stratified-take-drop(@data, $spec, $labels, Bool :$hash = True) is export {*}

multi stratified-take-drop(@data, $spec, Str $label, Bool :$hash = True) {
    return stratified-take-drop(@data, $spec, [$label, ], :$hash);
}

multi stratified-take-drop(@data, $spec, @labels, Bool :$hash = True) {

    my @tdSplit =
        group-by(@data, @labels).map({
            my ($take, $drop) = take-drop($_.value.Array, $spec)>>.Array;
            { :$take, :$drop } }).Array;

    my %split = take => @tdSplit.map({ $_.<take> }).&flatten.Array,
                drop => @tdSplit.map({ $_.<drop> }).&flatten.Array;

    return $hash ?? %split !! (%split<take>, %split<drop>);
}

#===========================================================
#| Determines if given data is reshapable.
#| (For example, a Positional of Maps.)
#| C<:$iterable-type> - Expected type of the given argument.
#| C<:$record-type> - Expected type of the elements of the given argument.
our proto is-reshapable($data, |) is export {*}

multi is-reshapable($data, *%args) {
    return Data::Reshapers::TypeSystem.is-reshapable($data, |%args);
}

multi is-reshapable($iterable-type, $record-type, $data) {
    Data::Reshapers::TypeSystem.is-reshapable($data, :$iterable-type, :$record-type)
}

#===========================================================
#| Returns the record types of the given argument.
our proto record-types($data) is export {*}

multi record-types($data) {
    return Data::Reshapers::TypeSystem.record-types($data);
}

#===========================================================
#| Deduces the type of the given argument.
our proto deduce-type($data,|) is export {*}

multi deduce-type($data, UInt :$max-enum-elems = 6, UInt :$max-struct-elems = 16, UInt :$max-tuple-elems = 16, Bool :$tally = False) {
    my $ts = Data::Reshapers::TypeSystem.new(:$max-enum-elems, :$max-struct-elems, :$max-tuple-elems);
    return $ts.deduce-type($data, :$tally);
}

#===========================================================
#| Completes each of the records of the given dataset to have column names found across all records.
#| C<$data> -- Dataset.
#| C<:$missing-value> - Missing value to use.
our proto complete-column-names(|) is export {*}

multi complete-column-names(**@args, *%args) {
    Data::Reshapers::ToPrettyTable::CompleteColumnNames(|@args, |%args)
}

#===========================================================
#| Makes a pretty ASCII table for a given dataset.
our proto to-pretty-table(|) is export {*}

multi to-pretty-table(**@args, *%args) {
    Data::Reshapers::ToPrettyTable::ToPrettyTable(|@args, |%args)
}