package WWW::Wow::RealmStatus;

use warnings;
use strict;

our $VERSION = '0.5';

use LWP::UserAgent;
use Cache::Memcached;
use XML::Descent;
use JSON::XS;

use constant BASE_URL => 'http://www.worldofwarcraft.com';
use constant US_REALMS => '/realmstatus/status.xml';
# http://www.worldofwarcraft.com/realmstatus/status.xml
# http://www.worldofwarcraft.com/realmstatus/realmstatus.xsl

sub new {
	my ($class, %args) = @_;
    if (! exists $args{'memcached_servers'}) {
        die 'You must specify a list of memcached servers.';
    }
	my $self = bless { %args }, $class;
    $self->{'memd'} = Cache::Memcached->new({
        'servers' => $args{'memcached_servers'},
        'debug' => 0,
    });
    if (! exists $args{'realmstatus_url'}) {
        $self->{'realmstatus_url'} = BASE_URL . US_REALMS;
    }
	return $self;
}

sub process {
    my ($self) = @_;
    my $ua = LWP::UserAgent->new();
    my $response = $ua->get($self->{'realmstatus_url'});
    if (! $response->is_success) {
        die $response->status_line;
    }
    my $content = $response->content();
    my @realms = $self->_ret_realms($content);
    for my $realm (@realms) {
        my $name = $realm->{'n'};
        my $key = $self->_get_realmkey($name);
        $self->{'memd'}->set(
            $key,
            {
                'name' => $realm->{'n'},
                'status' => $realm->{'s'} eq '1' ? 'up' : 'down',
                'type' => $self->_realm_type($realm->{'t'}),
                'population' => $self->_realm_population($realm->{'l'}),
            }
        );
    }
    return @realms;
}

sub save_realms {
    my ($self, @names) = @_;
    $self->{'memd'}->set(
        'wow:realms:list',
        \@names,
    );
    return 1;
}

sub get_realms {
    my ($self) = @_;
    my $realms = $self->{'memd'}->get('wow:realms:list');
    return @{$realms || []}
}

sub _realm_type {
    my ($self, $c) = @_;
    if ($c eq '1') { return 'PVE'; }
    if ($c eq '2') { return 'PVP' };
    if ($c eq '3') { return 'RP' };
    return 'PVPRP'
}

sub _realm_population {
    my ($self, $c) = @_;
    if ($c eq '2') { return 'Medium' };
    if ($c eq '3') { return 'High' };
    if ($c eq '4') { return 'Max' };
    return 'Low'
}

sub _ret_realms {
    my ($self, $xml, @nodes) = @_;
    my $p = XML::Descent->new({ 'Input' => \$xml });
    $p->on('rs' => sub {
        my ($elem, $attr, $ctx) = @_;
        $p->on('r' => sub {
            my ($elem, $attr, $ctx) = @_;
            push @nodes, $attr;
        });
        $p->walk;
    });
    $p->walk;
    return @nodes;
}

sub _get_realmkey {
    my ($self, $realm) = @_;
    my $key = "wow:realm:$realm";
    $key =~ s#\s+##g;
    return $key;
}

sub realm {
    my ($self, @realms) = @_;
    if (! @realms) { return 0; }
    my @out;
    for my $realm (@realms) {
        my $key = $self->_get_realmkey($realm);
        my $t = $self->{'memd'}->get($key);
        push @out, $t;
    }
    if (! @out) { return 0; }
    if (scalar @out == 1) { return $out[0]; }
    return @out;
}

sub realm_json {
    my ($self, @realms) = @_;
    my @data = $self->realm(@realms);
    my $retstr = to_json \@data;
    return $retstr;
}

=pod

=head1 NAME

WWW::Wow::RealmStatus - The great new WWW::Wow::RealmStatus!

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

  use WWW::Wow::RealmStatus;

  my $rs = WWW::Wow::RealmStatus->new(
    'memcached_servers' => ['localhost:11211']
  );
  @realms = $rs->process();
  print $rs->realm_json('Medivh');

=head1 FUNCTIONS

=head2 new

Creates a new object. When creating a new WWW::Wow::RealmStatus object you
must pass in a list of one or more memcached_servers. This module currently
does not support any other storage types other than one or more memcached
servers.

=head2 process

This method fetches the status file from worldofwarcraft.com and stuffs the
realm info into key/value pairs in memcached.

The _ret_realms method is used to process the xml file using XML::Descent.

The _get_realmkey method is used to create the memcached key from the realm
name.

This method also uses the _realm_type and _realm_population private methods
to output more human friendly values.

=head2 save_realms

This is a helper method that takes a number of realm names as an array and
puts them into memcached keyed on 'wow:realms:list'.

=head2 get_realms

This is a helper method take gets the realm list stored in memcached as set
by the save_realms method.

=head2 realm

This method fetches the realm data for one or more named realms.

=head2 realm_json

This method fetches the realm data for one or more named realms and returns
a json encoded string of realm data.

=head1 AUTHOR

Nick Gerakines, C<< <nick at gerakines.net> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-www-wow-realmstatus at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=WWW-Wow-RealmStatus>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc WWW::Wow::RealmStatus

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/WWW-Wow-RealmStatus>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/WWW-Wow-RealmStatus>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=WWW-Wow-RealmStatus>

=item * Search CPAN

L<http://search.cpan.org/dist/WWW-Wow-RealmStatus>

=back

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2007 Nick Gerakines, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;

