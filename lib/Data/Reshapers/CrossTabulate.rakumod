=begin pod

=head1 Data::Reshapers::CrossTabulate

C<Data::Reshapers::CrossTabulate> package module has data cross tabulation functions over
different data structures coercible to full-arrays.

=head1 Synopsis

    use Data::Reshapers;
    use Data::Reshapers::CrossTabulate;

    my @tbl = get-titanic-dataset();

    my $xtab1 = CrossTabulate(@tbl, 'passengerClass', 'passengerSex');
    my $xtab2 = CrossTabulate(@tbl, 'passengerClass', 'passengerSex', 'passengerAge');

    my @tbl2 = $csv.csv(in => $fileName, headers => "none");
    my $xtab3 = CrossTabulate(@tbl, 1, 3);
    my $xtab4 = CrossTabulate(@tbl, 1, 3, 2);

=end pod

unit module Data::Reshapers::CrossTabulate;

use Data::Reshapers::TypeSystem;

#===========================================================
our proto CrossTabulate(|) is export {*}

#-----------------------------------------------------------
#| Count or sum using two or three columns wrt number of columns.
multi CrossTabulate($tbl where Data::Reshapers::TypeSystem.is-reshapable(Positional, Positional, $tbl)) {

    if Data::Reshapers::TypeSystem.has-homogeneous-shape($tbl) {
        given $tbl[0].elems {
            when 1 { return CrossTabulate($tbl, 0); }
            when 2 { return CrossTabulate($tbl, 0, 1); }
            when $_ ≥ 3 { return CrossTabulate($tbl, 0, 1, 2); }
        }
    } else {
        note 'Do not know how to process jagged array of arrays.';
        return Nil;
    }
}

#| Count or sum using two or three keys respectively.
multi CrossTabulate(@tbl, Str:D $rowVarName, Str $columnVarName?, Str $valueVarName? ) {

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
        if $columnVarName {
            %res = @arr-of-hashes.classify({ $_{($rowVarName, $columnVarName)} })
        } else {
            # If no second column is specified classify with "default" first level key,
            # in order to obtain %res that is similar to 'main' case.
            %res = @arr-of-hashes.classify({ ('ONE', $_{$rowVarName}) })
        };
    }

    if $! {
        note "Not all records have the keys $rowVarName and $columnVarName.";
        return Nil;
    }

    # Summarize per group
    my %res2;
    if $valueVarName {

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

    # If no second column is specified return single hash
    if not $columnVarName {
        %res2 = %res2{'ONE'}
    }

    # Result
    return %res2;
}

#-----------------------------------------------------------
#| Count or sum using two or three indexes respectively
multi CrossTabulate(@tbl, UInt:D $rowIndex, UInt $columnIndex?, UInt $valueIndex?) {

    # One-liner summarizing the implementation below
    #my %res = @tbl.classify( { ($_[$rowIndex], $_[$columnIndex]) } ).duckmap({ $_.duckmap({$_[$valueIndex]}).sum });

    # Note that we could have (likely) optimized the case when @tbl an array-of-arrays using
    # if @tbl.isa(Array[Array]) { ...

    if @tbl.isa(Array) and @tbl.shape.elems > 2 {
        note 'Cannot work with multi-dimensional arrays. Sorry.';
        return Nil;
    } elsif @tbl.isa(Array)  and @tbl.shape.elems == 2 {
        my $arr = @tbl.flat.rotor( @tbl.shape()[1] );
        return CrossTabulate( $arr, $rowIndex, $columnIndex, $valueIndex )
    }

    # Coerce into array-of-arrays
    my Positional @arr-of-arrays;
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
        with $columnIndex {
            %res = @arr-of-arrays.classify({ $_[($rowIndex, $columnIndex)] });
        } else {
            %res = @arr-of-arrays.classify({ ('ONE', $_[($rowIndex)]) });
        }
    }

    if $! {
        note "Not all records have the indexes $rowIndex and $columnIndex.";
        return Nil;
    }

    # Summarize per group
    my %res2;
    with $valueIndex {

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

    # If no second column is specified return single hash
    without $columnIndex {
        %res2 = %res2{'ONE'}
    }

    # Result
    return %res2;
}