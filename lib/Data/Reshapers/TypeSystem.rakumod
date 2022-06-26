use v6.d;

use Data::Reshapers::Predicates;
use Hash::Ordered;

#===========================================================
role Data::Reshapers::TypeSystem::Type {
    has $.type is rw;
    has $.count is rw;
    submethod BUILD(:$!type = Any, :$!count = 1) {}
    multi method new($type, $count) {
        self.bless(:$type, :$count)
    }
    method Str(-->Str) {
        self.gist;
    }
};

class Data::Reshapers::TypeSystem::Atom
        does Data::Reshapers::TypeSystem::Type {
    method gist(-->Str) {
        'Atom[' ~ $.type.^name ~ ']'
    }
};

class Data::Reshapers::TypeSystem::Vector
        does Data::Reshapers::TypeSystem::Type {
    method gist(-->Str) {
        'Vector[(' ~ $.type>>.gist.join(', ') ~ ')]'
    }
};

class Data::Reshapers::TypeSystem::Tuple
        does Data::Reshapers::TypeSystem::Type {
    method gist(-->Str) {
        'Tuple[(' ~ $.type>>.gist.join(', ') ~ ')]'
    }
};

class Data::Reshapers::TypeSystem::Assoc
        does Data::Reshapers::TypeSystem::Type {

};

class Data::Reshapers::TypeSystem::Struct
        does Data::Reshapers::TypeSystem::Type {
    has $.keys;
    has $.values;

    submethod BUILD(:$!keys = Any, :$!values = Any) {}
    multi method new($keys, $values) {
        self.bless(:$keys, :$values)
    }

    method gist(-->Str) {
        'Struct[(' ~ $!keys.join(', ') ~ '), (' ~ $!values.map({ $_.^name }).join(', ') ~ ')]';
    }
};

#===========================================================

#multi sub circumfix:<%O( )> (@p) { Hash::Ordered.new.STORE: @p }

#===========================================================
class Data::Reshapers::TypeSystem {

    #------------------------------------------------------------
    method has-homogeneous-shape($l) {
        so $l[*].&{ $_».elems.all == $_[0].elems }
    }

    #------------------------------------------------------------
    method has-homogeneous-type($l) {
        so $l[*].&{ $_».are.all eqv $_[0].are }
    }

    #------------------------------------------------------------
    proto method is-reshapable(|) {*}

    multi method is-reshapable($data, :$iterable-type = Positional, :$record-type = Hash) {
        $data ~~ $iterable-type and ([and] $data.map({ $_ ~~ $record-type }))
    }

    multi method is-reshapable($iterable-type, $record-type, $data) {
        self.is-reshapable($data, :$iterable-type, :$record-type)
    }

    #------------------------------------------------------------
    method record-types($data) {

        my $types;

        given $data {
            when is-array-of-pairs($_) {
                $types = $data>>.are.map({ $_.map({ $_.key => $_.value }).Hash });
            }

            when self.is-reshapable(Positional, Map, $_) {
                $types = $data>>.are.map({ $_.map({ $_.key => $_.value }).Hash });
            }

            when is-hash-of-hashes($_) {
                return %( $_.keys Z=> self.record-types($_.values));
            }

            when $_ ~~ List {
                $types = $_.map({ $_.are });
            }

            when $_ ~~ Map {
                $types = $_.map({ $_.key => $_.value }).Hash;
            }

            default {
                warn 'Do not know how to find the type(s) of the given record(s).';
            }
        }

        return $types;
    }

    #------------------------------------------------------------
    multi method deduce-type($data) {
        given $data {
            when $_ ~~ Int { return Data::Reshapers::TypeSystem::Atom.new(Int, 1) }
            when $_ ~~ Str { return Data::Reshapers::TypeSystem::Atom.new(Str, 1) }

            when $_ ~~ List && self.has-homogeneous-type($_) {
                return Data::Reshapers::TypeSystem::Vector.new(self.deduce-type($_[0]), $_.elems)
            }

            when $_ ~~ List {
                my $t = $_.map({ self.deduce-type($_) }).List;
                return Data::Reshapers::TypeSystem::Tuple.new($t, 1)
            }

            when $_ ~~ Hash {
                my @res = |$_>>.are.sort({ $_.key });
                return Data::Reshapers::TypeSystem::Struct.new(keys => @res>>.key.List, values => @res>>.value.List);
            }

            default { return self.record-types($_) }
        }
    }
}