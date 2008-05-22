package WWW::Yahoo::KeywordExtractor;

use warnings;
use strict;

use Digest::MD5 qw(md5_hex);
use LWP::UserAgent;
use URI::Escape;
use XML::Simple;

our $VERSION = '0.01';

sub new {
	my ($class, %args) = @_;
	my $self = bless {%args}, $class;
	$self->{'ua'} = LWP::UserAgent->new;
	return $self;
}

sub extract {
	my ($self, %args) = @_;
	if (! $args{'content'}) { die 'No content specified'; }
	my $content_hash = md5_hex($args{'content'});
	if (! $self->{'__cache'.$content_hash}) {
		my $response = $self->{'ua'}->get('http://api.search.yahoo.com/ContentAnalysisService/V1/termExtraction?appid=WWWYahooKeywordExtractor&query=null&context='.uri_escape($args{'content'}));
		if (! $response->is_success) {
			die "Error getting data!\n";
		}
		my $xml = $response->content;
		my $ref = XMLin($xml, ForceArray => [ 'Result' ]);
		my @results = @{$ref->{'Result'}};
		$self->{'__cache'.$content_hash} = \@results;
	}
	return $self->{'__cache'.$content_hash};
}

=head1 NAME

WWW::Yahoo::KeywordExtractor - Get keywords from summary text via the Yahoo API

=head1 SYNOPSIS

This module will submit content to the Yahoo keyword extractor API to return
a list of relevant keywords.

  use WWW::Yahoo::KeywordExtractor;
  my $yke = WWW::Yahoo::KeywordExtractor->new();
  my $keywords = $yke->extract(content => 'My wife and I love to cook together. Carolyn surprises me with new things to love about her everyday.');
  print join q{}. 'Keyword 1: ', $keywords->[0], "\n";

=head1 SUBROUTINES/METHOD

=head2 new

The new subroutine creates and returns a WWW:Yahoo::KeywordExtractor object.

=head2 extract

This method will return a list of keywords based on sample data. It will die
if there is no 'content' arg given.

=head1 CACHING

This module will attempt to cache its data locally. It does this by creating
content cache keys which are md5 hashes of content. Sooner or later I will
update this module to also provide a list of content cache keys.

=head1 AUTHOR

Nick Gerakines, C<< <nick at socklabs.com> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-www-yahoo-keywordextractor at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=WWW-Yahoo-KeywordExtractor>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc WWW::Yahoo::KeywordExtractor

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/WWW-Yahoo-KeywordExtractor>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/WWW-Yahoo-KeywordExtractor>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=WWW-Yahoo-KeywordExtractor>

=item * Search CPAN

L<http://search.cpan.org/dist/WWW-Yahoo-KeywordExtractor>

=back

=head1 ACKNOWLEDGEMENTS

Thanks to the bright developers at Yahoo for creating a nifty keyword API.

=head1 COPYRIGHT & LICENSE

Copyright 2006 Nick Gerakines, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
