package WWW::Search::Feedster;

use strict;

use XML::Simple;
use WWW::Search qw(generic_option);
use WWW::SearchResult;

use vars qw(@ISA $VERSION);
no warnings qw(redefine);

@ISA = qw(WWW::Search);
$VERSION = '0.03';

sub native_setup_search {
	my($self, $query) = @_;
	$self->user_agent('W3SearchFeedster');
	$self->{'_next_to_retrieve'} = 0;
	$self->{_query} = $query;
}

sub native_retrieve_some {
	my ($self) = @_;
	$self->{_query} =~ s/ /%20/g;
	my $url = 'http://www.feedster.com/search/type/rss/'.$self->{_query};
	my $ua = LWP::UserAgent->new;
	my $response = $ua->get( $url );
	return unless ( $response->is_success );
	return unless ( my $content = $response->content );
	if ( $content ) {
		my $xs = new XML::Simple();
		my $ref = $xs->XMLin("$content" );
		foreach my $item ( @{ $ref->{'channel'}{'item'} }) {
			my $hit = WWW::SearchResult->new();
			$hit->title($item->{'title'});
			$hit->url($item->{'link'});
			$hit->description($item->{'description'});
			$hit->index_date($item->{'feedstersearch:epochAdded'});
			push @{$self->{cache}}, $hit;
		}
	}
	return;
}

=head1 NAME

WWW::Search::Feedster - Search Feedster

=head1 SYNOPSIS

  use WWW::Search;
  my $search = WWW::Search->new('Feedster');
  $search->native_query('gerakines');
  while (my $result = $search->next_result() ) {
    print $result->title."\n";
    print $result->url."\n";
    print $result->description."\n";
  }

=head1 DESCRIPTION

Class specialization of WWW::Search for searching http://www.feedster.com.

=head1 AUTHOR

Nick Gerakines E<lt>F<nick@socklabs.com>E<gt>

=head1 COPYRIGHT

Copyright (C) 2005-2006, Nick Gerakines

This module is free software; you can redistribute it or modify it
under the same terms as Perl itself.

=cut

1;
