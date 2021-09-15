=begin pod

=head1 Data::Reshapers::ToWideFormat

C<Data::Reshapers::ToLongFormat> package module has functions that convert data structures coercible to full-arrays
into corresponding wide formats. The central data structure is a positional (list or array) of hashes.

=head1 Synopsis


=end pod

unit module Data::Reshapers::ToWideFormat;

#===========================================================
our proto auto-aggregator(|) is export {*}

multi auto-aggregator(Num @vec ) { @vec.sum }

multi auto-aggregator(Str @vec) { @vec.join(', ') }

multi auto-aggregator($vec) {
    my Num @arr;
    try { @arr = $vec }
    if $! { $vec.join('; ') }
    else { auto-aggregator(@arr) }
}


#===========================================================
our proto ToWideFormat(|) is export {*}

#-----------------------------------------------------------
#| To long form conversion for arrays of hashes.
multi ToWideFormat(@tbl, $idColsSpec, Str:D $variableColName, Str:D $valueColName,
                     Str:D :$automaticKeysTo = 'AutomaticKey', :&aggregationFunction = &auto-aggregator) {

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
        my $k = 0;
        @arr-of-hashes = @arr-of-hashes.map({ $_.push( [$automaticKeysTo] Z=> [$k++] ) });

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
        note "If the second arguments is not Nil or [] then it is expected to be a columns name of the dataset.";
        return Nil;
    }


    if $variableColName !(elem) @allCols or $valueColName !(elem) @allCols {
        note "If the third and fourth arguments are expected to be columns names of the dataset.";
        return Nil;
    }

    # Determine aggregation function
    if !&aggregationFunction { &aggregationFunction = &auto-aggregator; }

    # Break-down into groups
    my $sep = ' , ';
    my @res = @arr-of-hashes.categorize({ $_{ |@idColsLocal, $variableColName}.join($sep) });

    # Aggregate
    @res =
            do for @res -> $p {
                my $aggrRes = &aggregationFunction( $p.value.map({ $_{$valueColName} }) );

                # Delete the pair corresponding to the aggregated column
                my %h = $p.value[0];
                my $var = %h{$variableColName}:delete;
                %h{$valueColName}:delete;
                # %h{%h.keys.grep(* !(elem) [$valueColName])}:p

                %h.push( [$var] Z=> [$aggrRes] )
            };

    # Breakdown by ID columns only
    @res = @res.categorize({ $_{ |@idColsLocal }.join($sep) });

    # Make the wide form records
    @res =
            do for @res -> $p {
                # Merge the hashes for each unique combination of values from the ID columns
                my %hres;
                %hres = do for |$p.value -> %h {
                    %hres = %hres , %h
                }
            }

    # Result
    return @res.sort({ $_{@idColsLocal} });
}