use Data::TypeSystem::Predicates;

unit module Data::Reshapers::Adapters;

proto convert-to-hash-of-hashes(|) is export {*}

multi convert-to-hash-of-hashes(@tbl where is-array-of-key-array-pairs($_) --> Hash) {
    @tbl.map({ $_.key => ($_.value.keys».Str.List Z=> $_.value.List).Hash }).Hash;
}

# Trivial but defined to be consistent and documentation purposes.
multi convert-to-hash-of-hashes(@tbl where is-array-of-key-hash-pairs($_) --> Hash) {
    @tbl.Hash;
}
