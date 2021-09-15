=begin pod

=head1 Data::Reshapers::ToPrettyTable

C<Data::Reshapers::ToPrettyTable> package module has data transformation functions over
different data structures coercible to full-arrays.

=head1 Synopsis

    use Data::Reshapers;
    use Data::Reshapers::ToPrettyTable;

    my @tbl = get-titanic-data(headers => "auto");
    say ToPrettyTable(@tbl);

=end pod

use Pretty::Table;

unit module Data::Reshapers::ToPrettyTable;

#===========================================================
#| Convert into a pretty table object.
our proto ToPrettyTable(|) is export {*}

#-----------------------------------------------------------
multi ToPrettyTable( %tbl, *%args) {

    my @colnames = %tbl{%tbl.keys[0]}.keys;

    my $tableObj = Pretty::Table.new:
            field-names => ['', |@colnames],
            sort-by => '',
            align => %('' => 'l'),
            |%args;

    %tbl.map({ $tableObj.add-row([ $_.key, |$_.value{|@colnames} ]) });

    return $tableObj;
}

#-----------------------------------------------------------
multi ToPrettyTable(@tbl, *%args) {

    # Coerce into array-of-hashes
    my Hash @arr-of-hashes;
    my Array @arr-of-arrays;

    try {
        @arr-of-hashes = @tbl
    }

    if $! {

        try {
            @arr-of-hashes = @tbl
        }

        if $! {
            note 'The first argument is expected to be an array that can be coerced into an array-of-hashes if the rest of the arguments are strings.';
            return Nil;
        }
    }


    with @arr-of-hashes {

        my @colnames = @arr-of-hashes[0].keys;

        my $tableObj = Pretty::Table.new:
                field-names => @colnames,
                |%args;

        @arr-of-hashes.map({ $tableObj.add-row( $_{|@colnames} ) });

        return $tableObj;

    } else {

        my @colnames = 1 ... @arr-of-arrays.values[0].elems;

        my $tableObj = Pretty::Table.new:
                field-names => @colnames,
                |%args;

        @arr-of-arrays.map({ $tableObj.add-row( $_[|@colnames] ) });

        return $tableObj;

    }

    # Result
    return Nil;
}