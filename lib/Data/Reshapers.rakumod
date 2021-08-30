=begin pod

=head1 Data::Reshapers

C<Data::Reshapers> package ha data reshaping functions for
different data structures (full arrays, Red tables, Text::CSV tables.)

=head1 Synopsis

    use Data::Reshapers;
    use Text::CSV;

    my $csv = Text::CSV.new;
    my $fileName = %?RESOURCES<dfTitanic.csv>;
    my @tbl = $csv.csv(in => $fileName, headers => "auto");

    my $xtab1 = cross-tabulate(@tbl, 'passengerClass', 'passengerSex');
    my $xtab2 = cross-tabulate(@tbl, 'passengerClass', 'passengerSex', 'passengerAge');

    my @tbl2 = $csv.csv(in => $fileName, headers => "none");
    my $xtab3 = cross-tabulate(@tbl, 1, 3);
    my $xtab4 = cross-tabulate(@tbl, 1, 3, 2);

=end pod

unit module Data::Reshapers;

#===========================================================
proto cross-tabulate(|) is export {*}

#-----------------------------------------------------------
#| Count or sum using two or three keys respectively
multi cross-tabulate(@tbl, Str:D $rowVarName, Str:D $columnVarName, Str $valueVarName = '') {

    # One-liner summarizing the implementation below
    #my %res = @tbl.classify( { ($_{$rowVarName}, $_{$columnVarName}) } ).duckmap({ $_.duckmap({$_{$valueVarName}}).sum });

    # Coerce into array-of-hashes
    my Hash @arr-of-hashes;
    try {
        @arr-of-hashes = @tbl
    }

    if $! {
        note 'The first argument is expected to be an array that can be coerced into an array-of-hashes if the rest of the arguments are strings.';
        return Nil;
    }

    # Break-down into groups
    my %res;
    try {
        %res = @arr-of-hashes.classify({ ($_{$rowVarName}, $_{$columnVarName}) });
    }

    if $! {
        note "Not all records have the keys $rowVarName and $columnVarName.";
        return Nil;
    }

    # Summarize per group
    my %res2;
    if $valueVarName.chars > 0 {

        try {
            %res2 = do for %res.kv -> $k, $v {
                $k => Hash( do for $v.kv -> $k1, $v1 { $k1 => $v1.map({ $_{$valueVarName} }).sum } )
            }
        }

        if $! {
            note "Not all records allow summation with the key $valueVarName.";
            return Nil;
        }

    } else {

        %res2 = do for %res.kv -> $k, $v {
            $k => Hash( do for $v.kv -> $k1, $v1 { $k1 => $v1.elems } )
        }

    }

    # Result
    return %res2;
}

#-----------------------------------------------------------
#| Count or sum using two or three indexes respectively
multi cross-tabulate(@tbl, UInt:D $rowIndex, UInt:D $columnIndex, Int $valueIndex = -1) {

    # One-liner summarizing the implementation below
    #my %res = @tbl.classify( { ($_[$rowIndex], $_[$columnIndex]) } ).duckmap({ $_.duckmap({$_[$valueIndex]}).sum });

    # Note that we could have (likely) optimized the case when @tbl an array-of-arrays using
    # if @tbl.isa(Array[Array]) { ...

    # Coerce into array-of-arrays
    my Array @arr-of-arrays;
    try {
        @arr-of-arrays = @tbl
    }

    if $! {
        note 'The first argument is expected to be an array that is or can be coerced into an array-of-arrays if the rest of the arguments are integers.';
        return Nil;
    }

    # Break-down into groups
    my %res;
    try {
        %res = @arr-of-arrays.classify({ ($_[$rowIndex], $_[$columnIndex]) });
    }

    if $! {
        note "Not all records have the indexes $rowIndex and $columnIndex.";
        return Nil;
    }

    # Summarize per group
    my %res2;
    if $valueIndex >= 0 {

        try {
            %res2 = do for %res.kv -> $k, $v {
                $k => Hash( do for $v.kv -> $k1, $v1 { $k1 => $v1.map({ $_[$valueIndex] }).sum } )
            }
        }

        if $! {
            note "Not all records allow summation with the index $valueIndex.";
            return Nil;
        }

    } else {

        %res2 = do for %res.kv -> $k, $v {
            $k => Hash( do for $v.kv -> $k1, $v1 { $k1 => $v1.elems } )
        }

    }

    # Result
    return %res2;
}