package WWW::Search::ISBNDB;

use strict;
no warnings qw(redefine);

use Carp;
use LWP::UserAgent;
use WWW::Search qw(generic_option);
use WWW::SearchResult;
use XML::Simple;
use vars qw(@ISA $VERSION);

@ISA = qw(WWW::Search);
$VERSION = "0.1";

=head1 NAME

WWW::Search::ISBNDB - Search for book information on isbndb.com

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

This module creates an easy to use interface for searching books on isbndb.com.

  use WWW::Search;  
  my $search = WWW::Search->new('ISBNDB', key => 'abcd1234');
  $search->native_query("born in blood");
  while (my $result = $search->next_result() ) {
    print $result->{isbn}.' - '.$result->{book_id}, "\n";
    print $result->{title}.' - '.$result->url, "\n";
  }

=head1 DETAILS

=head2 native_setup_search

This prepares the search by checking for a valid developer key. A developer key can be obtained at isbndb.com and is free.

=cut

sub native_setup_search {
	my($self, $query) = @_;
	croak("No license key given to WWW::Search::ISBDB!") unless ( $self->{key} && $self->{key} =~ m/^[a-zA-Z0-9]+$/ );
	$self->{_offset} = 0;
	$self->{_query} = $query;
}

=head2 native_retrieve_some

The logic behind this module is very simple. First we prepare the search
query that includes the access_key, search type, search value and display
options and fetch the page with L<LWP::UserAgent>. Once we have the results, 
we use L<XML::Simple> to sift through them and populate a L<WWW::SearchResult>
object.

Note that because of the complexity of the search result, it does not have all
of the default WWW::SearchResult fields. The extra fields are contained within
the object hash and consist of the following:

  book_id
  idbn
  language
  summary
  titlelong
  notes

=cut

sub native_retrieve_some {
	my ($self) = @_;
	
	# HACK: Consider better url encoding.
	$self->{_query} =~ s/ /%20/g;

	my %args = (
		'access_key' => $self->{key},
		'index1' => $self->{_type} || 'combined',
		'value1' => $self->{_query},
		'results' => 'details+subjects+texts',
	);
	
	my $url = 'http://isbndb.com/api/books.xml?'.( join( '&',  map { "$_=".$args{$_} } keys %args) );

	my $ua = LWP::UserAgent->new;
	my $response = $ua->get( $url );

	return unless ( $response->is_success );
	return unless ( my $content = $response->content );

	if ( $content ) {
		my $xs = new XML::Simple();
		my $ref = $xs->XMLin("$content" );
		foreach my $book ( @{ $ref->{'BookList'}{'BookData'} }) {
			my $hit = WWW::SearchResult->new();
			$hit->{'book_id'} = $book->{'book_id'};
			$hit->{'isbn'} = $book->{'isbn'};
			$hit->{'language'} = $book->{'Details'}{'language'} || '';
			$hit->{'summary'} = $book->{'Summary'} || '';
			$hit->{'titlelong'} = $book->{'TitleLong'} || '';
			$hit->{'notes'} = $book->{'Notes'} || '';
			$hit->title( $book->{'Title'} );
			$hit->url( 'http://isbndb.com/search-all.html?kw='.$book->{'isbn'} );
			push @{$self->{cache}}, $hit;
		}
	}
	return;
}

1;

=head1 INSTALLATION

To install this module, run the following commands:

  perl Build.PL
  ./Build
  ./Build test
  ./Build install

=head1 AUTHOR

Nick Gerakines, C<< <nick@socklabs.com> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-www-search-isbndb@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=WWW-Search-ISBNDB>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 ACKNOWLEDGEMENTS

Thanks to isbndb.com for the data that powers this module.

I have no affiliation whatsoever with this website, staff or affiliates.

If you are bored, check out my website: http://www.socklabs.com/

=head1 COPYRIGHT & LICENSE

Copyright 2005 Nick Gerakines, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
