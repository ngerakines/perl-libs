package WWW::Search::Feedster;

use strict;
use Carp;

use XML::RSS::LibXML;
use WWW::Search qw(generic_option);
use WWW::SearchResult;

use vars qw(@ISA $VERSION);
no warnings qw(redefine);

@ISA = qw(WWW::Search);
$VERSION = "0.01";

=head1 NAME

WWW::Search::Feedster - Search a Bookmarks server via XMLRPC

=head1 SYNOPSIS

  use WWW::Search;
  my $search = WWW::Search->new(
    'Feedster',
  );
  $search->native_query('world of warcraft linux');
  while (my $result = $search->next_result() ) {
    print $result->title, "\n";
    print $result->url, "\n";
    print $result->description, "\n";
  }

=head1 DESCRIPTION

This is an implimentation of Feedster search results as part of the WWW::Search
library. This module makes use of the rss export functionality of Feedster
search results to easily parse and return data.

This class exports no public interface; all interaction should be done through
L<WWW::Search> objects.

=cut

sub native_setup_search {
	my($self, $query) = @_;
	
	$self->user_agent('non-robot');
	$self->{'_next_to_retrieve'} = 0;
	$self->{search_host} ||= 'http://feedster.com';
	$self->{search_path} ||= '/search.php';

	my $limit = $self->{limit} || 20;
	my $sort = $self->{sort} || 'date';
	my %search_args = (
		q => $query,
		sort => $sort,
		limit => $limit,
		ie => 'UTF-8',
		hl => '',
		type => 'rss',
	);
	$self->{_next_url} =
		$self->{'search_host'}.$self->{'search_path'}.'?'.
		join( "&", map { "$_=$search_args{$_}" } keys %search_args );
}

sub native_retrieve_some {
	my ($self) = @_;

	return unless ( defined $self->{_next_url} );

	my ($response) = $self->http_request('GET', $self->{_next_url});

	$self->{response} = $response;
	
	return unless ( $response->is_success );
	
	my $res_source = $response->content();

	$self->{_next_url} = undef;

	$res_source =~ s!^<\?xml.*\n!!g;

	my $hits_found = 0;

	if ( $response ) {
		my $rss = XML::RSS::LibXML->new;
		$rss->parse($res_source);
		foreach my $item ( @{ $rss->{items} } ) {
			$hits_found++;
			my $hit = WWW::SearchResult->new();
			$hit->title( $item->{title} );
			$hit->url( $item->{link} );
			$hit->description( $item->{description} );
			push @{$self->{cache}}, $hit if $hit;
		}
	}
	return $hits_found;
}

1;

=head1 AUTHOR

Nick Gerakines E<lt>F<nick@socklabs.com>E<gt>

=head1 COPYRIGHT

Copyright (C) 2005, Nick Gerakines

This module is free software; you can redistribute it or modify it
under the same terms as Perl itself.

=cut
