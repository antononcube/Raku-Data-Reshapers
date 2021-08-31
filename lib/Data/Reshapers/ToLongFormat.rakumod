=begin pod

=head1 Data::Reshapers::ToLongFormat

C<Data::Reshapers::ToLongFormat> package module has data cross tabulation functions over
different data structures coercible to full-arrays.

=head1 Synopsis


=end pod

unit module Data::Reshapers::ToLongFormat;

#===========================================================
proto to-long-format(|) is export {*}

#-----------------------------------------------------------
#| Count or sum using two or three keys respectively
multi to-long-format(@tbl, @idcols, @valCols, Str:D :$automaticKeysTo = 'ID', Str:D :$variablesTo = 'Variable', Str:D :$valuesTo = 'Value' ) {

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
    my @res =
            do for @valCols -> $vc {
                |@arr-of-hashes.map({ Hash( $_{@idcols}:p ).push( Hash( [ $variablesTo, $valuesTo] Z=> [$vc, $_{$vc}] ) ) });
            };

    #@res = @res.reduce( { $^a.append( $^b )});

    # Result
    return @res.sort({ $_{@idcols} });
}