unit module Data::Reshapers::Predicates;

# From gfldex over Discord #raku channel.
#| Returns True if the argument is a list of hashes or lists that have the same number of elements.
multi has-homogeneous-shape(\l) is export {
    so \l[*].&{ $_».elems.all == $_[0] }
}

multi has-homogeneous-shape(@l where $_.all ~~ Pair) is export {
    has-homogeneous-shape(@l.map({ .values }))
}

#| Returns True if the argument is a list of hashes and all hashes have the same keys.
sub has-homogeneous-keys(\l) is export {
    l[0].isa(Hash) and so l[*].&{ $_».keys».sort.all == $_[0].keys.sort }
}

sub record-types(\l) is export {
    if l[*].all ~~ Positional or l[*].all ~~ Map {

        l[*].&{ $_.map({ $_.deepmap({ $_.^name }) }) }

    } else {
        Nil
    }
}

#| Returns True if the argument is a positional of Hashes and the value types of all hashes are the same.
sub has-homogeneous-hash-types(\l) is export {
    l[0].isa(Hash) and so l[*].&{ $_.map({ $_.values.map({ $_.^name }) }).all == $_[0].values.map({ $_.^name }) }
}

#| Returns True if the argument is a list of lists and the element types of all lists are the same.
sub has-homogeneous-array-types(\l) is export {
    (l[0].isa(Positional) or l[0].isa(Array)) and so l[*].&{ $_.map({ $_.map({ $_.^name }) }).all == $_[0].map({ $_.^name }) }
}

sub is-array-of-key-array-pairs(@arr) is export {
    (@arr.all ~~ Pair) and has-homogeneous-shape(@arr)
}