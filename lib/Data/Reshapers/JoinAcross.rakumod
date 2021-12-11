=begin pod

=head1 Data::Reshapers::JoinAcross

C<Data::Reshapers::JoinAcross> package module has functions that join two arrays-of-hashes.

=end pod

use Hash::Merge;
use Data::Reshapers::Predicates;

unit module Data::Reshapers::JoinAcross;

#===========================================================
our proto JoinAcross(|) is export {*}

#-----------------------------------------------------------
#| Join across (SQL JOIN) for arrays of hashes.
multi JoinAcross(@a, @b, Str $key, Str :$join-spec= 'Inner',
                 Bool :$fill = True, :$missing-value = Whatever,
                 :&key-collision-function = WhateverCode) {
    return JoinAcross(@a, @b, $key => $key, :$join-spec, :$fill, :$missing-value, :&key-collision-function)
}

#| Join across (SQL JOIN) for arrays of hashes.
multi JoinAcross(@a, @b, Pair $keyMap, Str :$join-spec= 'Inner',
                 Bool :$fill = True, :$missing-value = Whatever,
                 :&key-collision-function = WhateverCode) {

    if $join-spec.lc !(elem) <Inner Left Right Outer>>>.lc {
        die "The argument 'join-spec' is expected to be one of 'Inner', 'Left', 'Right', or 'Outer'.";
    }

    if !is-array-of-hashes(@a) {
        die "The first argument is expected to be an array of hashes."
    }

    if !is-array-of-hashes(@b) {
        die "The second argument is expected to be an array of hashes."
    }

    my $akey = $keyMap.key;
    my $bkey = $keyMap.value;

    my %ah = @a.map({ $_{$akey} => $_ });
    my %bh = @b.map({ $_{$bkey} => $_ });

    my $commonKeys =
            do if $join-spec.lc eq 'inner' {
                Set(%ah.keys) (&) Set(%bh.keys)
            } elsif $join-spec.lc eq 'left' {
                Set(%ah.keys)
            } elsif $join-spec.lc eq 'right' {
                Set(%bh.keys)
            } elsif $join-spec.lc eq 'outer' {
                Set(%ah.keys) (|) Set(%bh.keys)
            } else {
                die "Uknown join spec: $join-spec."
            }

    my @res = push(%ah.grep({ $_.key (elem) $commonKeys }).Hash, %bh.grep({ $_.key (elem) $commonKeys }).Hash );

    my @res2 = @res.map({ $_.value.reduce(&merge-hash) });

    if $fill {
        my $allKeys = Set(@res2>>.keys);
        my %default = $allKeys.keys Z=> ($missing-value xx $allKeys);
        @res2 = @res2.map({ merge-hash(%default, $_ ) })
    }

    return @res2;
}