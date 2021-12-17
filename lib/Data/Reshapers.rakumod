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

multi select-columns($data, Str $var, :&chooser = &infix:<(elem)>) {
    return select-columns($data, [$var,])
}

multi select-columns(@data, %mapper) {
    return rename-columns(select-columns(@data, %mapper.keys), %mapper)
}

multi select-columns(@data, @vars, :&chooser = &infix:<(elem)>) {
    if is-array-of-hashes(@data) {
        my %colSet = Set(@vars);
        my $res = @data>>.grep({ &chooser($_.key, %colSet) })>>.Hash;
        return $res;
    } else {
        die "If the first argument is an array then it is expected to be an array of hashes."
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
our proto summarize-at(|) is export {*}

multi summarize-at($data, Str $var, @funcs, Str :$sep = '.') {
    return summarize-at($data, [$var, ], @funcs, :$sep)
}

multi summarize-at($data, @vars, &func, Str :$sep = '.') {
    return summarize-at($data, @vars, [&func,], :$sep)
}

multi summarize-at($data, @vars, @funcs, Str :$sep = '.') {
    if @funcs.all ~~ Callable {

        if is-hash-of-hashes($data) {

            my %res = infix:<X>(transpose(select-columns($data, @vars)),
                    @funcs,
                    :with(-> $c, &f { $c.key ~ $sep ~ &f.name => $c.value.values.Array.&f }));

            return %res;

        } elsif is-array-of-hashes($data) {

            my %res = infix:<X>(transpose(select-columns($data, @vars)),
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
our proto to-pretty-table(|) is export {*}

multi to-pretty-table(**@args, *%args) {
    Data::Reshapers::ToPrettyTable::ToPrettyTable(|@args, |%args)
}
