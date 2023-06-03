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

use Data::TypeSystem::Predicates;
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

        # This original implementation assumes homogeneity of the records.
        # Obviously, not necessarily true. It can be applied for "optimization purposes"
        # after, say, deducing the type and making sure all records have same keys;
        #my %h-new;
        #for %hash-of-hashes.values.first.keys X %hash-of-hashes.keys -> ($new-key, $current-key) {
        #    %h-new{$new-key}{$current-key} = %hash-of-hashes{$current-key}{$new-key};
        #}

        # This is very ineffective for sparse hash-of-hashes,
        # because it uses the cartesian product of top-hash-keys and unique record keys.
        #my %h-new;
        #for %hash-of-hashes.values>>.keys.flat.unique X %hash-of-hashes.keys -> ($new-key, $current-key) {
        #    %h-new{$new-key}{$current-key} = %hash-of-hashes{$current-key}{$new-key};
        #}

        # Here we transpose existing pairs only. The sparsity is preserved.
        my @recordKeys = |%hash-of-hashes.values>>.keys.flat.unique;
        my %h-new = Hash(@recordKeys X=> Hash.new);

        for %hash-of-hashes.kv -> $tag, $mix {
            for $mix.kv -> $item, $val {
                %h-new{$item}.push($tag => $val)
            }
        }

        return %h-new>>.Hash;

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

        if has-homogeneous-keys(@arr-of-hashes) {

            # In the sparse case this is inefficient because of Cartesian product.
            my Array %thash;
            for @arr-of-hashes[0].keys X ^@arr-of-hashes.elems -> ($new-key, $current-index) {
                %thash{$new-key}[$current-index] = @arr-of-hashes[$current-index]{$new-key};
            }
            return %thash;

        } else {

            my @recordKeys = |@arr-of-hashes.values>>.keys.flat.unique;
            # It seems that this initialization is not needed:
            #my %h-new = Hash(@recordKeys X=> Hash.new);
            my %h-new;

            for @arr-of-hashes.kv -> $ind, $mix {
                for $mix.kv -> $item, $val {
                    %h-new{$item}.push($ind => $val)
                }
            }

            return %h-new>>.Hash;
        }

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