unit module Data::Reshapers::Predicates;

# From gfldex over Discord #raku channel.
sub has-homogeneous-shape(\l) is export {
    so l[*].&{ $_».elems.all == $_[0] }
}

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

sub has-homogeneous-hash-types(\l) is export {
    l[0].isa(Hash) and so l[*].&{ $_.map({ $_.values.map({ $_.^name }) }).all == $_[0].values.map({ $_.^name }) }
}

sub has-homogeneous-array-types(\l) is export {
    (l[0].isa(Positional) or l[0].isa(Array)) and so l[*].&{ $_.map({ $_.map({ $_.^name }) }).all == $_[0].map({ $_.^name }) }
}