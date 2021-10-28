=begin pod

=head1 Data::Reshapers::Transpose

C<Data::Reshapers::Transpose> package module has data transformation functions over
different data structures coercible to full-arrays.

=head1 Synopsis

    use Data::Reshapers;
    use Data::Reshapers::Transpose;

    my @tbl = get-titanic-data(headers => "auto").roll(5);
    say Transpose(@tbl);

=end pod

use Data::Reshapers::Predicates;
use Data::Reshapers::Adapters;

unit module Data::Reshapers::Transpose;

#===========================================================
#| Convert into a pretty table object.
our proto Transpose(|) is export {*}


#-----------------------------------------------------------
multi Transpose(%tbl) {

    my Hash %hash-of-hashes;
    my Positional %hash-of-arrays;

    # Coerces into hash of hashes
    try {
        %hash-of-hashes = %tbl;
    }

    if $! {

        # Coerce into array-of-hashes
        try {
            %hash-of-arrays = %tbl
        }

        if $! {
            fail 'If the first argument is a hash then it is expected that it can be coerced into a hash-of-hashes or a hash-of-positionals.';
        }
    }

    if %hash-of-hashes.defined and %hash-of-hashes {

        my %h-new;
        for %hash-of-hashes.values.first.keys X %hash-of-hashes.keys -> ($new-key, $current-key) {
            %h-new{$new-key}{$current-key} = %hash-of-hashes{$current-key}{$new-key};
        }

        return %h-new;

    } else {

        my Hash @arrNew;
        for ^%hash-of-arrays.values.first.elems X %hash-of-arrays.keys -> ($new-index, $current-key) {
            @arrNew[$new-index]{$current-key} = %hash-of-arrays{$current-key}[$new-index];
        }

        return @arrNew;
    }

    # Result
    return Nil;
}

#-----------------------------------------------------------
multi Transpose(@tbl) {

    my Hash @arr-of-hashes;
    my Positional @arr-of-arrays;

    # Coerce into array-of-hashes
    try {
        @arr-of-hashes = @tbl
    }

    if $! {

        # Coerce into array-of-hashes
        try {
            @arr-of-arrays = @tbl
        }

        if $! {
            # Check for an array of key-array pairs
            if is-array-of-key-array-pairs(@tbl) or is-array-of-key-hash-pairs(@tbl) {

                # Convert an array of key-[array|hash] pairs into a hash of hashes
                my %res = convert-to-hash-of-hashes(@tbl);

                return Transpose(%res)
            }

            fail 'If the first argument is an array then it is expected that it can be coerced into an array-of-hashes or an array-of-positionals.';
        }
    }

    # Convert to table
    if @arr-of-hashes.defined and @arr-of-hashes {

        my Array %thash;
        for @arr-of-hashes[0].keys X ^@arr-of-hashes.elems -> ($new-key, $current-index) {
            %thash{$new-key}[$current-index] = @arr-of-hashes[$current-index]{$new-key};
        }

        return %thash;

    } else {

        my Array @tarr;
        for ^@arr-of-arrays[0].elems X ^@arr-of-arrays.elems -> ($new-index, $current-index) {
            @tarr[$new-index][$current-index] = @arr-of-arrays[$current-index][$new-index];
        }

        return @tarr

    }

    # Result
    return Nil;
}