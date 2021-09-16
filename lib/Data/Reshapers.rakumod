=begin pod

=head1 Data::Reshapers

C<Data::Reshapers> package has data reshaping functions for
different data structures (full arrays, Red tables, Text::CSV tables.)

=head1 Synopsis

    use Data::Reshapers;

    my @tbl = get-titanic-dataset(headers => "auto");

    my $xtab1 = cross-tabulate(@tbl, 'passengerClass', 'passengerSex');
    my $xtab2 = cross-tabulate(@tbl, 'passengerClass', 'passengerSex', 'passengerAge');

    my @tbl2 = get-titanic-dataset(headers => "none");
    my $xtab3 = cross-tabulate(@tbl, 1, 3);
    my $xtab4 = cross-tabulate(@tbl, 1, 3, 2);

=end pod

unit module Data::Reshapers;

use Text::CSV;
use Data::Reshapers::CrossTabulate;
use Data::Reshapers::ToLongFormat;
use Data::Reshapers::ToWideFormat;
use Data::Reshapers::ToPrettyTable;
use Data::Reshapers::Transpose;

#===========================================================

#| Get the Titanic dataset. Returns Positional[Hash] or Positional[Array].
our sub get-titanic-dataset( Str:D :$headers = 'auto', --> Positional ) is export {
    my $csv = Text::CSV.new;
    my $fileHandle = %?RESOURCES<dfTitanic.csv>;

    my @tbl = $csv.csv(in => $fileHandle.Str, :$headers);

    return @tbl;
}
#| Ingests the resource file "dfTitanic.csv" of Data::Reshapers.

#===========================================================
our proto cross-tabulate(|) is export {*}

multi cross-tabulate( **@args ) {
    Data::Reshapers::CrossTabulate::CrossTabulate( |@args )
}

#===========================================================
our proto to-long-format(|) is export {*}

multi to-long-format( **@args, *%args ) {
    Data::Reshapers::ToLongFormat::ToLongFormat( |@args, |%args )
}

#===========================================================
our proto transpose(|) is export {*}

multi transpose( **@args ) {
    Data::Reshapers::Transpose::Transpose( |@args )
}

#===========================================================
our proto to-wide-format(|) is export {*}

multi to-wide-format( **@args, *%args ) {
    Data::Reshapers::ToWideFormat::ToWideFormat( |@args, |%args )
}

#===========================================================
our proto data-reshape(|) is export {*}

multi data-reshape('cross-tabulate', **@args ) {
    cross-tabulate( |@args )
}

multi data-reshape('to-long-format', **@args, *%args ) {
    to-long-format( |@args, |%args )
}

multi data-reshape('to-wide-format', **@args, *%args ) {
    to-wide-format( |@args, |%args )
}

multi data-reshape('transpose', **@args ) {
    transpose( |@args )
}

#===========================================================
our proto to-pretty-table(|) is export {*}

multi to-pretty-table( **@args, *%args ) {
    Data::Reshapers::ToPrettyTable::ToPrettyTable( |@args, |%args )
}
