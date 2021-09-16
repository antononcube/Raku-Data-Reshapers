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
multi ToPrettyTable(%tbl, *%args) {

    # Assuming we have hash of hashes
    my Hash %tblLocal;
    try {
        %tblLocal = %tbl;
    }

    if $! {
        fail 'If the first argument is a hash then it is expected that it can be coerced into a hash-of-hashes.';
    }

    # Column names of the pretty table
    my @colnames = %tbl{%tbl.keys[0]}.keys;

    # Initialize the pretty table object
    my $tableObj = Pretty::Table.new:
            field-names => ['', |@colnames],
            sort-by => '',
            align => %('' => 'l'),
            |%args;

    # Add each hash into the pretty table as table row
    %tbl.map({ $tableObj.add-row([$_.key, |$_.value{|@colnames}]) });

    # Result
    return $tableObj;
}

#-----------------------------------------------------------
multi ToPrettyTable(@tbl, *%args) {

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
            fail 'If the first argument is an array then it is expected that it can be coerced into an array-of-hashes or an array-of-positionals.';
        }
    }

    # Convert to table
    if @arr-of-hashes.defined and @arr-of-hashes {

        # Column names of the pretty table
        my @colnames = @arr-of-hashes[0].keys;

        # Initialize the pretty table object
        my $tableObj = Pretty::Table.new:
                field-names => @colnames,
                |%args;

        # Add each hash into the pretty table as table row
        @arr-of-hashes.map({ $tableObj.add-row($_{|@colnames}) });

        return $tableObj;

    } else {

        # Column names of the pretty table
        my @colnames = ^@arr-of-arrays.values[0].elems;

        # Initialize the pretty table object
        my $tableObj = Pretty::Table.new:
                field-names => @colnames>>.Str,
                |%args;

        # Add each hash into the pretty table as table row
        @arr-of-arrays.map({ $tableObj.add-row($_[|@colnames]) });

        return $tableObj;

    }

    # Result
    return Nil;
}