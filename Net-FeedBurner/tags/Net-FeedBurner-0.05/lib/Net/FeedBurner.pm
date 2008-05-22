# $Id: $ $Revision: $ $Source: $ $Date: $

package Net::FeedBurner;

use warnings;
use strict;

use LWP::UserAgent;
use XML::Simple;

our $VERSION = '0.05';

sub new {
	my ($class, %args) = @_;
	my $self = bless { %args }, $class;
	$self->init();
	return $self;
}

sub init {
	my ($self) = @_;
	$self->{'ua'} = LWP::UserAgent->new;
	$self->{'valid_requests'} = {
		'FindFeeds' => {
			'url' => 'https://api.feedburner.com/management/1.0/FindFeeds',
			'args' => [qw/user password/],
		},
		'GetFeed' => {
			'url' => 'https://api.feedburner.com/management/1.0/GetFeed',
			'args' => [qw/user password id/],
		},
		'AddFeed' => {
			'url' => 'https://api.feedburner.com/management/1.0/AddFeed',
			'args' => [qw/user password feed/],
			'type' => 'post',
		},
		'DeleteFeed' => {
			'url' => 'https://api.feedburner.com/management/1.0/DeleteFeed',
			'args' => [qw/user password id/],
			'type' => 'post',
		},
		'ResyncFeed' => {
			'url' => 'https://api.feedburner.com/management/1.0/ResyncFeed',
			'args' => [qw/user password id/],
			'type' => 'post',
		},
		'ModifyFeed' => {
			'url' => 'https://api.feedburner.com/management/1.0/ModifyFeed',
			'args' => [qw/user password feed/],
			'type' => 'post',
		},
	};
	return 1;
}

sub urlbuilder {
	my ($self, $type, %args) = @_;
	if (! $self->{'valid_requests'}{$type}) {
		die 'Requesting unknown request type : '.$type;
	}
	my $url = $self->{'valid_requests'}{$type}{'url'};
	if ($self->{'valid_requests'}{$type}{'args'} && ! $self->{'valid_requests'}{$type}{'type'}) {
		$url .= q{?}.(join q{&}, map { $_.q{=}.($self->{$_} || $args{$_} || q{})  } @{ $self->{'valid_requests'}{$type}{'args'} } );
	}
	return $url;
}

sub request {
	my ($self, %args) = @_;
	my ($response);
	if ($args{'type'} && $args{'type'} eq 'post') {
		$response = $self->{'ua'}->post($args{'url'}, $args{'form'} );
	} else {
		$response = $self->{'ua'}->get($args{'url'});
	}
	if (! $response->is_success) {
		die join q{}, 'Bad response: ', $response->code, ' - ', $response->status_line, ' - ', $args{'url'};
	}
	my $xs = XML::Simple->new();
	my $ref = $xs->XMLin($response->content, %{$args{'xargs'}});
	if ($ref->{'stat'} ne 'ok') {
		die Data::Dumper::Dumper($ref);
	}
	$self->{'rawxml'} = $response->content;
	return $ref;
}

sub find_feeds {
	my ($self) = @_;
	my $ref = $self->request(
		'url' => $self->urlbuilder('FindFeeds'),
		'xargs' => {
			'KeyAttr' => [qw/feeds/],
		}
	);
	my %feeds = map {
		$_->{'id'} => {
			'id' => $_->{'id'},
			'title' => $_->{'title'},
			'uri' => $_->{'uri'},
		}
	} @{ $ref->{'feeds'}->{'feed'}};
	return \%feeds;
}

sub get_feed {
	my ($self, $id) = @_;
	my $ref = $self->request(
		'url' => $self->urlbuilder('GetFeed', 'id' => $id),
	);
	my %feed = (
		'url' => $ref->{'feed'}{'source'}{'url'},
		'id' => $ref->{'feed'}{'id'},
		'title' => $ref->{'feed'}{'title'},
		'uri' => $ref->{'feed'}{'uri'},
	);
	return \%feed;
}

sub add_feed {
	my ($self, $feed) = @_;
	my $ref = $self->request(
		'url' => $self->urlbuilder('AddFeed'),
		'form' => {
			'feed' => $feed,
			'user' => $self->{'user'},
			'password' => $self->{'password'},
		},
		'type' => 'post',
	);
	my %feed = (
		'url' => $ref->{'feed'}{'source'}{'url'},
		'id' => $ref->{'feed'}{'id'},
		'title' => $ref->{'feed'}{'title'},
		'uri' => $ref->{'feed'}{'uri'},
	);
	return \%feed;
}

sub delete_feed {
	my ($self, $id) = @_;
	my $ref = $self->request(
		'url' => $self->urlbuilder('DeleteFeed'),
		'form' => {
			'id' => $id,
		},
		'type' => 'post',
	);
	return 0;
}

sub modify_feed {
	my ($self, $feed) = @_;
	my $ref = $self->request(
		'url' => $self->urlbuilder('ModifyFeed'),
		'form' => {
			'feed' => $feed,
			'user' => $self->{'user'},
			'password' => $self->{'password'},
		},
		'type' => 'post',
	);
	my %feed = (
		'url' => $ref->{'feed'}{'source'}{'url'},
		'id' => $ref->{'feed'}{'id'},
		'title' => $ref->{'feed'}{'title'},
		'uri' => $ref->{'feed'}{'uri'},
	);
	return \%feed;
}

sub resync_feed {
	my ($self, $id) = @_;
	my $ref = $self->request(
		'url' => $self->urlbuilder('ResyncFeed'),
		'form' => {
			'id' => $id,
		},
		'type' => 'post',
	);
	return 0;
}

1;
__END__

=pod

=head1 NAME

Net::FeedBurner - The great new Net::FeedBurner!

=head1 SYNOPSIS

  use Net::FeedBurner;
  my $fb = Net::FeedBurner->new('user' => $user, 'password' => $password);
  my $feeds = $fb->find_feeds();
  my $feed_id = (keys %{$feeds})[0];
  my $feedinfo = $fb->get_feed($feed_id);
  my $feedxml = '<feed ... />'; # See t/20-usage.t for more complex usage examples
  $feedburner->modify_feed($feedxml);

=head1 FUNCTIONS

Please note that the API documentation at FeedBurner is excellent. Please
check the developer documentation there before raising questions here. This
module is NOT meant to be a definative guide to the FeedBurner API, just an
abstraction layer to make using the FeedBurner API easier for perl developers.

=head2 new

Creates and returns a Net::FeedBurner object.

=head2 init

Does some internal init actions.

=head2 urlbuilder

Create a proper url depending on request name and type.

=head2 request

Make a request and perform some basic error checking and parsing.

=head2 find_feeds

Use the API to return a list of feeds for a particular user.

=head2 get_feed

Use the API to return the details of a particular feed. 

=head2 add_feed

Use the API to allow the user to add a new feed to their account.

=head2 delete_feed

Use the API to allow the user to delete a feed in their account.

=head2 modify_feed

Use the API to allow the user to modify a feed in their account.

=head2 resync_feed

Use the API to allow the user to resync a feed in their account. This will
involves clearing the cache, resetting any podcast media enclosures, and
informing the caller of any feed formatting problems.

=head1 CAVEATS

After a request it will store the original xmldata for later use.

  my $fb = Net::FeedBurner->new( ... );
  my $fb->get_feed(1234);
  my $xml = $fb->{'rawxml};
  # ...

=head1 AUTHOR

Nick Gerakines, C<< <nick at socklabs.com> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-net-feedburner at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Net-FeedBurner>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Net::FeedBurner

You can also look for information at:

=over 4

=item * FeedBurner Developer Area

L<http://www.feedburner.com/fb/a/api/management/docs>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Net-FeedBurner>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Net-FeedBurner>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Net-FeedBurner>

=item * Search CPAN

L<http://search.cpan.org/dist/Net-FeedBurner>

=back

=head1 ACKNOWLEDGEMENTS

Thanks to the developers over at FeedBurner who wrote really awesome
documentation to the FeedBurner API.

  http://www.feedburner.com/fb/a/developers
  http://www.feedburner.com/fb/a/api/management/docs

=head1 COPYRIGHT & LICENSE

Copyright 2006 Nick Gerakines, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
