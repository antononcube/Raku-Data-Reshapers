=begin pod

=head1 Data::Reshapers::ToLongFormat

C<Data::Reshapers::ToLongFormat> package module has functions that convert data structures coercible to full-arrays
into corresponding long formats. The central data structure is a positional (list or array) of hashes.

=end pod

unit module Data::Reshapers::ToLongFormat;

#===========================================================
our proto ToLongFormat(|) is export {*}

#-----------------------------------------------------------
multi ToLongFormat(@tbl) {
    ToLongFormat(@tbl, [], [])
}

#-----------------------------------------------------------
#| To long form conversion for arrays of hashes.
multi ToLongFormat(@tbl, $idColsSpec, $valColsSpec,
                     Str:D :$automaticKeysTo = 'AutomaticKey',
                     Str:D :$variablesTo = 'Variable',
                     Str:D :$valuesTo = 'Value') {

    # Coerce into array-of-hashes
    my Hash @arr-of-hashes;
    try {
        @arr-of-hashes = @tbl
    }

    if $! {
        note 'The first argument is expected to be an array that can be coerced into an array-of-hashes if the rest of the arguments are strings.';
        return Nil;
    }

    # All columns
    my @allCols = @arr-of-hashes[0].keys;

    # Determine ID columns
    my Str @idColsLocal;

    if !(so $idColsSpec) or $idColsSpec eq $[] {

        @idColsLocal = [$automaticKeysTo];

        # Add automatic IDs.
        # Note the cloning of each record -- this might be reconsidered for optimization purposes.
        my $k = 0;
        @arr-of-hashes = @arr-of-hashes.map({ $_.clone.push( [$automaticKeysTo] Z=> [$k++] ) });

        @allCols.push( $automaticKeysTo );

    } elsif $idColsSpec.isa(Str) and $idColsSpec.lc (elem) @allCols {

        @idColsLocal = [$idColsSpec]

    } else {
        try {
            @idColsLocal = $idColsSpec.list
        }

        if $! {
            note 'The second argument is expected to be a string or an array strings.';
            return Nil;
        }
    };

    if (@idColsLocal (&) @allCols).elems < @idColsLocal.elems {
        note "If the second and third arguments are not Nil or [] then they are expected to be columns names of the dataset.";
        return Nil;
    }

    # Determine value columns
    my Str @valColsLocal;

    if !(so $valColsSpec) or $valColsSpec eq $[] {

        @valColsLocal = (@allCols (-) @idColsLocal).keys;

    } elsif $valColsSpec.isa(Str) and $valColsSpec.lc (elem) @allCols {

        @$valColsSpec = [$valColsSpec]

    } else {
        try {
            @valColsLocal = $valColsSpec.list
        }

        if $! {
            note 'The third argument is expected to be a string or an array strings.';
            return Nil;
        }
    }

    if (@valColsLocal (&) @allCols).elems < @valColsLocal.elems {
        note "If the second and third arguments are not Nil or [] then they are expected to be columns names of the dataset.";
        return Nil;
    }

    # Break-down into groups
    my @res =
            do for @valColsLocal -> $vc {
                |@arr-of-hashes.map({ Hash($_{@idColsLocal}:p).push(Hash([$variablesTo, $valuesTo] Z=> [$vc, $_{$vc}])) });
            }

    #@res = @res.reduce( { $^a.append( $^b )});

    # Result
    # Converting to a list since some of the operations produce Seq.
    return @res.sort({ $_{@idColsLocal} }).List;
}