use Data::Reshapers::Predicates;

unit module Data::Reshapers::Adapters;

sub convert-to-hash-of-hashes(@tbl where is-array-of-key-array-pairs($_) --> Hash) is export {
    @tbl.map({ $_.key => ($_.value.keys».Str.List Z=> $_.value.List).Hash }).Hash;
}
