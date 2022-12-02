=begin pod

=head1 Data::Reshapers::JoinAcross

C<Data::Reshapers::JoinAcross> package module has functions that join two arrays-of-hashes.

=end pod

use Hash::Merge;
use Data::Reshapers::Predicates;

unit module Data::Reshapers::JoinAcross;

#===========================================================
sub make-combined-key( %h, @keys, Str :$sep = ':::' ) {
    return @keys.map({ %h{$_} }).join($sep)
}

#===========================================================
#| Join across (SQL JOIN) for arrays of hashes.
our proto JoinAcross(|) is export {*}

#-----------------------------------------------------------
#| Join across (SQL JOIN) for arrays of hashes.
multi JoinAcross(@a, @b, Str $key, *%args) {
    return JoinAcross(@a, @b, $key => $key, |%args)
}

#| Join across (SQL JOIN) for arrays of hashes.
multi JoinAcross(@a, @b, @keys, *%args) {
    my %keyMap;
    if @keys.all ~~ Str {
        %keyMap = @keys.map({ $_ => $_ })
    } elsif @keys.all ~~ Pair  {
        %keyMap = @keys
    } else {
        die 'When the third argument is an array then it is expected to be an array of strings or an array of pairs.'
    }

    return JoinAcross(@a, @b, %keyMap, |%args)
}

#| Join across (SQL JOIN) for arrays of hashes.
multi JoinAcross(@a, @b, Pair $keyMap, *%args) {
    return JoinAcross(@a, @b, %($keyMap), |%args)
}

#| Anti join for arrays of hashes.
multi JoinAcross(@a, @b, %keyMap, Str :$join-spec where *.lc (elem) <anti semi>, *%args) {

    if !is-array-of-hashes(@a) {
        die "The first argument is expected to be an array of hashes."
    }

    if !is-array-of-hashes(@b) {
        die "The second argument is expected to be an array of hashes."
    }

    my (@ap, @bpKeys);
    if %keyMap.elems == 1 {
        my $akey = %keyMap.first.key;
        my $bkey = %keyMap.first.value;

        @ap = @a.map({ $_{$akey} => $_ });
        @bpKeys = @b.map({ $_{$bkey} });
    } elsif %keyMap.elems > 1 {
        @ap = @a.map({ make-combined-key($_, %keyMap.keys) => $_ });
        @bpKeys = @b.map({ make-combined-key($_, %keyMap.values) });
    } else {
        die 'The third argument is expected to be non-empty value.'
    }

    my $commonKeys =
            do if $join-spec.lc eq 'anti' {
                Set(@ap>>.key) (-) Set(@bpKeys);
            } else {
                Set(@ap>>.key) (&) Set(@bpKeys);
            }

    my @res = @ap.grep({ $_.key (elem) $commonKeys })>>.value;

    return @res;
}

#| Join across (SQL JOIN) for arrays of hashes.
multi JoinAcross(@a, @b, %keyMap, Str :$join-spec = 'Inner',
                 Bool :$fill = True, :$missing-value = Whatever,
                 :&key-collision-function = WhateverCode) {

    if $join-spec.lc !(elem) <Inner Left Right Outer>>>.lc {
        die "The argument 'join-spec' is expected to be one of 'Anti', 'Inner', 'Left', 'Right', or 'Outer'.";
    }

    if !is-array-of-hashes(@a) {
        die "The first argument is expected to be an array of hashes."
    }

    if !is-array-of-hashes(@b) {
        die "The second argument is expected to be an array of hashes."
    }

    my (%ah, %bh);
    if %keyMap.elems == 1 {
        my $akey = %keyMap.first.key;
        my $bkey = %keyMap.first.value;

        %ah = @a.map({ $_{$akey} => $_ });
        %bh = @b.map({ $_{$bkey} => $_ });
    } elsif %keyMap.elems > 1 {
        %ah = @a.map({ make-combined-key($_, %keyMap.keys) => $_ });
        %bh = @b.map({ make-combined-key($_, %keyMap.values) => $_ });
    } else {
        die 'The third argument is expected to be non-empty value.'
    }

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

    my @res2 = @res.map({ $_.value.reduce( { merge-hash($^a, $^b, :!deep) } ) });

    if $fill {
        my $allKeys = Set(@res2>>.keys);
        my %default = $allKeys.keys Z=> ($missing-value xx $allKeys);
        @res2 = @res2.map({ merge-hash(%default, $_ ) })
    }

    return @res2;
}