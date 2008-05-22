# $Id: $ $Revision: $ $Source: $ $Date: $

package WWW::Search::Odeo;

use warnings;
use strict;

use LWP::UserAgent;
use WWW::Search;
use WWW::SearchResult;

use vars qw/@ISA/;

@ISA = qw( WWW::Search );

our $VERSION = '0.1';

# TODO: Force a random delay after the first search
# sub need_to_delay { return 0; }

# TODO: Test coverage only at 90%
# TODO: Clean up useragent, add tracking header for Odeo folks
# TODO: Look around to see if atom feeds are available
# TODO: Code cleanup -- doesn't pass Test::Perl::Critic

sub native_setup_search {
	my ($self, $query, $args) = @_;
	$self->{'type'} = $args->{'type'} ? $args->{'type'} : 'audio';
	$self->{_query} = $query || 'books';
	$self->{_offset} = 0;
	$self->user_agent('non-robot');
	return 1;
}

sub native_retrieve_some {
	my ($self) = @_;
	if ($self->{'search_count_' . $self->{'_query'}}) { return }
	my $url = 'http://www.odeo.com/rest/find/t/' . $self->{'type'} . q{/} . $self->{'_query'};
	my $response = $self->http_request('GET', $url);
	if (! $response->is_success) { die 'response bad - ' . $url; }
	my $results = $response->content();
	if ($results) {
		my @items;
		study $results;
		while ($results =~ m/<a href="\/audio\/(\d+)\/view">([^<]*)<\/a>\s+<\/dt>\s+<dd>(.*)([^d]{2})dd/ig) {
			my ($id, $title, $body) = ($1, $2, $3);
			$title =~ s/\n//igxm;
			$body =~ s/&hellip;/.../igxm;
			push @items, { 'id' => $id, 'title' => $title, 'body' => WWW::Search::strip_tags($body) };
		}
		$self->approximate_result_count(scalar @items);
		foreach my $item (@items) {
			my $hit = WWW::SearchResult->new();
			$hit->add_url('http://www.odeo.com/' . $self->{'type'} . q{/} . $item->{'id'} . '/view');
			$hit->title($item->{'title'});
			$hit->description($item->{'description'});
			push @{$self->{cache}}, $hit;
		}
	}
	$self->{'search_count_' . $self->{'_query'}} += 1;
	return 1;
}

1; # End of WWW::Search::Odeo
__END__

=pod

=head1 NAME

WWW::Search::Odeo - Find cool stuff in Odeo

=head1 SYNOPSIS

  use WWW::Search;
  my $search = WWW::Search->new('Odeo');
  $search->native_query('freemasonry');
  while (my $result = $search->next_result() ) {
    print $result->url . "\n";
    # ...
  }

=head1 DESCRIPTION

This module provides light search funtionality for Odeo.

=head1 FUNCTIONS

=head2 native_setup_search

Prepares our search based on the search type.

Valid search types are: audio (default), channel, profile and site

=head2 native_retrieve_some

Performs the actual search. Uses the REST API and some regex munging. Keeping
thing simple is the name of the game.

=head1 AUTHOR

Nick Gerakines, C<< <nick at socklabs.com> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-www-search-odeo at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=WWW-Search-Odeo>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc WWW::Search::Odeo

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/WWW-Search-Odeo>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/WWW-Search-Odeo>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=WWW-Search-Odeo>

=item * Search CPAN

L<http://search.cpan.org/dist/WWW-Search-Odeo>

=back

=head1 ACKNOWLEDGEMENTS

Thanks to Odeo for making a nifty product.

=head1 COPYRIGHT & LICENSE

Copyright 2006 Nick Gerakines, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
