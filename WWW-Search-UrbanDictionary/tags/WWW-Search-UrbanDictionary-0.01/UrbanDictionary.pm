package WWW::Search::UrbanDictionary;

use strict;
use Carp;
use SOAP::Lite;
use WWW::Search qw(generic_option);
use WWW::SearchResult;
use vars qw(@ISA $VERSION);
no warnings qw(redefine);

@ISA = qw(WWW::Search);
$VERSION = "0.1";

=head1 NAME

WWW::Search::UrbanDictionary - Search the Urban Dictionary via SOAP

=head1 SYNOPSIS

  use WWW::Search;

  my $key = 'abcdefghijklmnop1234567890';

  my $search = WWW::Search->new('UrbanDictionary', key => $key);

  $search->native_query("emo");

  while (my $result = $search->next_result() ) {
    print $result->{definition}, "\n";
    print $result->{author}, "\n";
    print $result->{example}, "\n";
    print $result->url, "\n";
    print "\n";
  }


=head1 DESCRIPTION

This class is an Urban Dictionary specialization of WWW::Search. It handles
searching Urban Dictionary F<http://www.urbandictionary.com/> using its new
SOAP API F<http://api.urbandictionary.com/>.

All interaction should be done through WWW::Search objects.

Note that you must register for an API account and have a valid Urban
Dictionary API license key before using this module.

This module reports errors via croak().

This module uses SOAP::Life to do all the dirty work.

=cut

sub native_setup_search {
	# print STDERR "Setup. Should only run once....\n";
	my($self, $query) = @_;
	my $key = $self->{key};
	croak("No license key given to WWW::Search::UrbanDictionary!") unless defined $key;
	$self->{_query} = $query;
	$self->{_offset} = 0;
}

sub native_retrieve_some {
	# print "Retrieve. This is the one with issues....\n";
	my $self = shift;
	my $key = $self->{key};
	my $query = $self->{_query};

	my $search = SOAP::Lite->service('http://api.urbandictionary.com/soap?wsdl');

	my $results = $search->lookup($key, $query);

	return unless defined $results;
	return if $self->{search_count} > 0;

	$self->approximate_result_count(scalar @$results);

	if ($results) {
		foreach my $element (@$results) {
			my $hit = WWW::SearchResult->new();
			$hit->{example} = $element->{example};
			$hit->url($element->{url});
			$hit->{author} = $element->{author};
			$hit->{description} = $element->{definition};
			$hit->{word} = $element->{word};
			push @{$self->{cache}}, $hit;
		}
	} else {
		return;
	}

	return if scalar(@$results) < 10;
	$self->{search_count} += 1;
	return 1;
}

1;

=head1 AUTHOR

Nick Gerakines E<lt>F<nick@socklabs.com>E<gt>

=head1 COPYRIGHT

Copyright (C) 2005, Nick Gerakines

This module is free software; you can redistribute it or modify it
under the same terms as Perl itself.

=cut
