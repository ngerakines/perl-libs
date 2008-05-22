
package Apache2::Mogile::Dispatch;

use strict;
use warnings;
use English;

use APR::Table ();
use APR::SockAddr ();
use Apache2::RequestRec ();
use Apache2::RequestUtil ();
use Apache2::Connection ();
use Apache2::Filter ();
use Apache2::RequestRec ();
use Apache2::Module;
use Apache2::CmdParms ();
use Apache2::Directive ();
use Apache2::Log ();
use Apache2::URI ();
use Apache2::Const -compile => qw(DECLINED OK OR_ALL RSRC_CONF TAKE1 RAW_ARGS NO_ARGS DONE NOT_FOUND);

use MogileFS;
use Cache::Memcached;

our $VERSION = '0.1_1';

my %ssi_types = (
    'text/html' => '.html',
);

my @directives = (
	{
        name         => 'MogAlways',
        func         => __PACKAGE__ . '::MogAlways',
        req_override => Apache2::Const::RSRC_CONF,
        args_how     => Apache2::Const::TAKE1,
        errmsg       => 'MogAlways string',
    },
	{
        name         => 'MogReproxyToken',
        func         => __PACKAGE__ . '::MogReproxyToken',
        req_override => Apache2::Const::RSRC_CONF,
        args_how     => Apache2::Const::TAKE1,
        errmsg       => 'MogReproxyToken hostname',
    },
    {
        name         => 'MogDirector',
        func         => __PACKAGE__ . '::MogDirector',
        req_override => Apache2::Const::RSRC_CONF,
        args_how     => Apache2::Const::TAKE1,
        errmsg       => 'MogDirector package',
    },
    {
        name         => 'MogDomain',
        func         => __PACKAGE__ . '::MogDomain',
        req_override => Apache2::Const::RSRC_CONF,
        args_how     => Apache2::Const::TAKE1,
        errmsg       => 'MogDomain hostname',
    },
    {
        name         => '<MogTrackers',
        func         => __PACKAGE__ . '::MogTrackers',
        req_override => Apache2::Const::RSRC_CONF,
        args_how     => Apache2::Const::RAW_ARGS,
        errmsg       => '<MogTrackers>
	    mog1 192.168.100.3:1325
	    mog2 192.168.100.4:1325
	    mog3 localhost:1325
	    mog4 localhost:1326
...
</MogTrackers>',
    },
    {
        name         => '</MogTrackers>',
        func         => __PACKAGE__ . '::MogTrackersEND',
        req_override => Apache2::Const::OR_ALL,
        args_how     => Apache2::Const::NO_ARGS,
        errmsg       => '</MogTrackers> without <MogTrackers>',
    },
    {
        name         => '<MogMemcaches',
        func         => __PACKAGE__ . '::MogMemcaches',
        req_override => Apache2::Const::RSRC_CONF,
        args_how     => Apache2::Const::RAW_ARGS,
        errmsg       => '<MogMemcaches>
	    memcache1 192.168.100.3:1425
	    memcache2 192.168.100.4:1425
	    memcache2 localhost:1425
...
</MogMemcaches>',
    },
    {
        name         => '</MogMemcaches>',
        func         => __PACKAGE__ . '::MogMemcachesEND',
        req_override => Apache2::Const::OR_ALL,
        args_how     => Apache2::Const::NO_ARGS,
        errmsg       => '</MogMemcaches> without <MogMemcaches>',
    },
    {
        name         => '<MogStaticServers',
        func         => __PACKAGE__ . '::MogStaticServers',
        req_override => Apache2::Const::RSRC_CONF,
        args_how     => Apache2::Const::RAW_ARGS,
        errmsg       => '<MogStaticServers>
	    web1 192.168.100.3:80
	    web2 192.168.100.4:80
	    web3 localhost:80
...
</MogStaticServers>',
    },
    {
        name         => '</MogStaticServers>',
        func         => __PACKAGE__ . '::MogStaticServersEND',
        req_override => Apache2::Const::OR_ALL,
        args_how     => Apache2::Const::NO_ARGS,
        errmsg       => '</MogStaticServers> without <MogStaticServers>',
    },
);

eval { Apache2::Module::add(__PACKAGE__, \@directives); };

sub MogAlways {
	my ($i, $parms, $arg) = @_;
    $i = Apache2::Module::get_config( __PACKAGE__, $parms->server );
    $i->{'MogAlways'} = $arg;	
}

sub MogReproxyToken {
	my ($i, $parms, $arg) = @_;
    $i = Apache2::Module::get_config( __PACKAGE__, $parms->server );
    $i->{'MogReproxyToken'} = $arg;
}

sub MogDirector {
	my ($i, $parms, $arg) = @_;
    $i = Apache2::Module::get_config( __PACKAGE__, $parms->server );
    $i->{'MogDirector'} = $arg;
}

sub MogDomain {
	my ($i, $parms, $arg) = @_;
    $i = Apache2::Module::get_config( __PACKAGE__, $parms->server );
    $i->{'MogDomain'} = $arg;
}

sub MogTrackers {
    my ($i, $parms, @args)=@_;
    $i = Apache2::Module::get_config( __PACKAGE__, $parms->server );
    $i->{'MogTrackers'} = _parse_serverlist( $parms->directive->as_string);
}

sub MogTrackersEND {
    die 'ERROR: </MogTrackers> without <MogTrackers>';
}

sub MogMemcaches {
    my ($i, $parms, @args)=@_;
    $i = Apache2::Module::get_config( __PACKAGE__, $parms->server );
    $i->{'MogMemcaches'} = _parse_serverlist( $parms->directive->as_string);
}

sub MogMemcachesEND {
    die 'ERROR: </MogMemcaches> without <MogMemcaches>';
}

sub MogStaticServers {
    my ($i, $parms, @args)=@_;
    $i = Apache2::Module::get_config( __PACKAGE__, $parms->server );
    $i->{'MogStaticServers'} = _parse_serverlist( $parms->directive->as_string);
}

sub MogStaticServersEND {
    die 'ERROR: </MogStaticServers> without <MogStaticServers>';
}

sub _parse_serverlist {
    my $conf = shift;
    my $a = [];
    foreach my $line (split /\r?\n/, $conf) {
        if( $line=~/^\s*(\w+):?\s+(.+?)\s*$/ ) {
            push @{$a}, [$1, $2];
        }
    }
    return $a;
}

sub handler {
    my ($r) = @_;

    my $cf = Apache2::Module::get_config(__PACKAGE__, $r->server);

    my $mog_trackers = $cf->{'MogTrackers'};
    my $mog_memcaches = $cf->{'MogMemcaches'};
    my $mog_staticservers = $cf->{'MogStaticServers'};
    my $mog_director = $cf->{'MogDirector'};
    my $mogile_domain = $cf->{'MogDomain'};
    my $mog_reproxy_token = $cf->{'MogReproxyToken'};
    my $mog_always = $cf->{'MogAlways'};

    my $file = $r->uri;
    my $requested_hostname = $r->hostname();

    my ($host_info, $memd);
    my $memkey = $mog_director->memcache_key($r, $cf);
    if ($mog_memcaches) {
        $memd = Cache::Memcached->new({
            'servers' => [ map { $_->[1] } @{$mog_memcaches} ],
        });
    }
    if ($memd) {
        $host_info = $memd->get($memkey);
    }
    if (! $host_info) {
        ($host_info) = $mog_director->get_direction($r, $cf);
        if ($host_info && $memd) {
            $memd->set($memkey, $host_info);
        }
    }
    if ($mog_always) {
        if ($mog_always eq 'mogile') {
            $host_info->{'mogile'} = 1;
        } else {
            $host_info->{'mogile'} = '0';
        }
    }
    if ($host_info && $host_info->{'reproxy'})  {
        $r->err_headers_out->add('X-REPROXY-URL', $host_info->{'reproxy'} );
        return Apache2::Const::DONE;
    }
    if (exists $host_info->{'mogile'} && $host_info->{'mogile'} eq '0') {
        if ($mog_reproxy_token) {
            $r->err_headers_out->add('X-REPROXY-SERVICE' => 'old_web');
        } else {
	        my $good_path = get_working_path(map { $_->[1] } @{$mog_staticservers || ''});
	        if (! $good_path) {
	            return Apache2::Const::NOT_FOUND;
	        }
            $r->err_headers_out->add('X-REPROXY-URL', $good_path );
        }
        return Apache2::Const::DONE;
    }
    if ($host_info && $host_info->{'mogile'}) {
        $file = ($host_info->{'canonical_domain'} ? '/' . $host_info->{'canonical_domain'} : '') . $r->uri;
        if ($file !~ m#^/#) { $file = '/' . $file; }
        my $mogfs = get_mogile_object([ map { $_->[1] } @{$mog_trackers} ], $mogile_domain);
        my @paths;
        eval { @paths = $mogfs->get_paths($file, 1); };
        if ($EVAL_ERROR) { return Apache2::Const::NOT_FOUND; }
        my $working_path = get_working_path(@paths);
        if (! $working_path) { return Apache2::Const::NOT_FOUND; }
        if ($file !~ m/\.html$/ && $file !~ m!/$!) {
            $r->err_headers_out->add('X-REPROXY-URL', $working_path );
            return Apache2::Const::DONE;
        }
        my $ua = LWP::UserAgent->new;
        my $response = $ua->get($working_path);
        if ($response->is_success) { $r->print($response->content); }
        return Apache2::Const::DONE;
    }
    return Apache2::Const::DONE;
}

sub get_mogile_object {
    my ($hosts, $domain) = @_;
    my $mog = MogileFS->new(
        hosts => $hosts,
        domain => $domain,
    );
    return $mog;
}

sub get_working_path {
    my (@uris) = @_;
    my $ua = LWP::UserAgent->new;
    for my $uri (@uris) {
        my $response = $ua->head($uri);
        if ($response->is_success) { return $uri; }
    }
    return 0;
}

1;
__END__

=pod

=head1 NAME

Apache2::Mogile::Dispatch - An Apache2 MogileFS Dispatcher

=head1 SYNOPSIS

Quickly and easily use MogileFS + Perlbal instead of Apache for static ( or
semi-static SSI ) file serving.

  # -- httpd.conf
  MogReproxyToken old_web
  MogDirector Socklabs::MogileDirector
  MogDomain socklabs
  <MogTrackers>
    mog1 192.168.100.3:1325
    mog2 192.168.100.4:1325
  </MogTrackers>
  <MogMemcaches>
    memcache1 192.168.100.3:1425
    memcache2 192.168.100.4:1425
  </MogMemcaches>

  PerlMapToStorageHandler Apache2::Const::OK
  SetOutputFilter INCLUDES
  <LocationMatch "^/">
      SetHandler modperl
      PerlHandler Apache2::Mogile::Dispatch
  </LocationMatch>

=head1 DESCRIPTION

Apache 2.x is an excellent platform for serving content, namely dynamic
content. Serving static content can become a gruesome task as your content
bank becomes bigger and more diverse. Thankfully we have distributed file
systems like MogileFS to easily distribute content efficiently while having
good and controllable redundancy.

Because really, who doesn't want redundancy?

This module also makes it easy* to migrate to MogileFS by calling a 'director'
with a few options and having it return a set of rules for
Apache2::Mogile::Dispatcher to follow. Currently the rules are based on the
hostname of the requested URI but could easily be modified to be based on
location specific rules.

To speed things up as much as possible this module makes use of
Cache::Memcached to cache as much of the decision information as possible.

* Nothing is ever easy.

=head1 CONFIGURATION

=head2 MogAlways

Don't use the director, simply use mogile or static.

  MogAlways mogile # Always use mogile
  MogAlways static # Always use static

Don't bother checking with the director -- Always try mogile.

=head2 MogReproxyToken

If a reproxy token is set and a given uri/file is not to be handled through
mogile then it will issue a 'X-REPROXY-SERVICE' => TOKEN_XYZ instead of
reproxying the url through one of the static servers.

Note that when this option is set the static servers directive is completely
ignored.

=head2 MogDirector

The MogDirector option allows the user to set a class that handles the
director functionality. Please see the example director for more information
on what is expected and required.

=head2 MogDomain

This option is passed on to mogile object creation.

=head2 MogTrackers

The MogTrackers directive sets the MogileFS trackers to query.

  <MogTrackers>
    mog1 192.168.100.3:1325
    mog2 192.168.100.4:1325
    mog3 localhost:1325
    mog4 localhost:1326
    ...
  </MogTrackers>

Note that the first column indicating node names really doesn't mean or do
anything.

=head2 MogMemcaches

Much like MogTrackers, this option sets the Memcache servers to query. If this
option is not set than memcache will not be used. It is very strongly
recommended that memcache be used.

  <MogMemcaches>
    memcache1 192.168.100.3:1425
    memcache2 192.168.100.4:1425
    memcache2 localhost:1425
    ...
  </MogMemcaches>

Note that the first column indicating node names really doesn't mean or do
anything.

=head2 MogStaticServers

Much like MogTrackers and MogMemcaches, this option sets the static servers to
reproxy to if a given file/uri is not handled by mogile. Note that this is
completely useless if mogile handles everything, via setting MogAlways to
'mogile'.

  <MogStaticServers>
    web1 http://192.168.100.3:80
    web2 http://192.168.100.4:80
    web3 http://localhost:80
    ...
  </MogStaticServers>

If Apache2::Mogile::Dispatch handles the uri '/socklabs/index.html' and the
director says that it is not infact to be handled by mogile, it will attempt
to content the static servers to request the file. In this case it starts at
the top and works its way through the list using the first one that returns
200 - OK. If none of them return then a 404 - Not Found is returned.

Note that the format for the reproxy is very simple:

  <static server x><uri>

=head2 handler

This function is the base handler. It does all of the work.

=head2 get_mogile_object

This function returns a mogile object used to query the mogile trackers.

=head2 get_working_path

This function attemps find a working url from a passed list of urls using HEAD
requests. It returns the first good one that it finds.

=head1 MISC

=head2 MogMemcachesEND

=head2 MogStaticServersEND

=head2 MogTrackersEND

=head1 AUTHOR

Nick Gerakines, C<< <nick at socklabs.com> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-apache2-mogile-dispatch at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Apache2-Mogile-Dispatch>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 CAVEATS

When supplied with a list of mogile or static servers it will attempt to
make a HEAD request to determine if the server can serve the file or not.

=head1 TODO

Allow a header or url argument check to force mogile/static use.

Better handling directories

Add fallback support -- When servering files it should fallback to either
mogile or static when it can't find what it wants.

Add more tests for per-directory configuration

Add more tests for mogile up/down situation

Add default Director class that can be subclassed

Add Apache2::Mogile::Dispatch::Cookbook with more usage examples and tips on
how to get the most out of perlbal + mogile + Apache2::Mogile::Dispatch.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

  perldoc Apache2::Mogile::Dispatch

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Apache2-Mogile-Dispatch>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Apache2-Mogile-Dispatch>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Apache2-Mogile-Dispatch>

=item * Search CPAN

L<http://search.cpan.org/dist/Apache2-Mogile-Dispatch>

=item * The socklabs-cpan project page

The project page: 
L<http://dev.socklabs.com/projects/cpan/>

The SVN repository:
L<http://dev.socklabs.com/svn/cpan/Apache2-Mogile-Dispatch/trunk/>

=item * MogileFS project page on Danga Interactive

L<http://www.danga.com/mogilefs/>

=back

=head1 ACKNOWLEDGEMENTS

Mark Smith
Brad Fitzpatrick
Brad Wittiker

=head1 COPYRIGHT & LICENSE

Copyright 2006 Nick Gerakines, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
