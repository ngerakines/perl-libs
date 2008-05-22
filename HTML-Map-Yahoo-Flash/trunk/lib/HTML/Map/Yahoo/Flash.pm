package HTML::Map::Yahoo::Flash;

use strict;
use warnings;

our $VERSION = 0.1;

sub new {
    my ($class, %args) = @_;
    if (! $args{'key'}) { die 'A key must be provided'; }
    my $self = bless { %args }, $class;
    return $self;
}

sub controls {
    my ($self, @controls) = @_;
    my %valid_controls = map { $_ => 1 } qw(pan);
    if (grep { !$valid_controls{$_} } @controls) { return 0; }
    return $self->{'controls'} = [ @controls ];
}

sub widgets {
    my ($self, @controls) = @_;
    my %valid_controls = map { $_ => 1 } qw(SatelliteControlWidget NavigatorWidget);
    if (grep { ! $valid_controls{$_} } @controls) { return 0; }
    return $self->{'widgets'} = [ @controls ];
}

sub add_marker {
    my ($self, %opts) = @_;
    push @{$self->{'points'}}, { %opts };
    return 1;
}

sub render {
    my ($self) = @_;
    $self->{'height'} ||= 480;
    $self->{'width'} ||= 600;

    my $text = <<'EOF';
<div id="mapContainer"></div>
<script type="text/javascript">

EOF

    my ($controls, $markers) = ('', '');

    if ($self->{'controls'}) {
        foreach my $control (@{$self->{'controls'}}) {
            if ($control eq 'pan') { $controls .= "map.addTool( new PanTool(), true );\n"; }
        }
    }
    if ($self->{'widgets'}) {
        for my $widget (@{$self->{'widgets'}}) {
            $controls .= "map.addWidget(new $widget());\n";
        }
    }

    my $i = 0;
    for my $point (@{$self->{'points'}}) {
        $i++;
        $text .= "var latlon_$i = new LatLon(" . $point->{'point'}[0] . ', ' . $point->{'point'}[1] . ");\n";
        $text .= "var marker_$i = new CustomPOIMarker( '" . ($point->{'title'} || '') . "', '" . ($point->{'description'} || '') . "', '" . ($point->{'html'} || '') . "', '0xFF0000', '0xFFFFFF');\n";
        $markers .= "map.addMarkerByLatLon( marker_$i, latlon_$i);\n";
    }

    if ($i) {
        $text .= <<"EOF";
var map = new Map("mapContainer", 'routemap', latlon_1, 3);
EOF
    } else {
        $text .= <<"EOF";
var map = new Map("mapContainer", 'routemap');
EOF
    }

    $text .= $controls . $markers;

    $text .= <<'EOF';

</script>
EOF

    my $js = '<script type="text/javascript" src="http://maps.yahooapis.com/v3.03/fl/javascript/apiloader.js?appid=' . $self->{'key'} . '"></script>';
    my $style = <<"EOF";
<style type="text/css" media="screen">
#mapContainer { 
  width: $self->{'width'}px;
  height: $self->{'height'}px
} 
</style>
EOF

    return (
        $js,
        $style,
        $text,
    );
}

1;
__END__

=pod

=head1 NAME

HTML::Map::Yahoo::Flash - The great new HTML::Map::Yahoo::Flash!

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

  use HTML::Map::Yahoo::Flash;
  
  my $map = HTML::Map::Yahoo::Flash->new( 'key' => 'test01' );
  ...

=head1 DESCRIPTION

This is a perl module.

=head1 FUNCTIONS

=head2 add_marker

=head2 controls

=head2 widgets

=head2 new

=head2 render

=head1 AUTHOR

Nick Gerakines, C<< <nick at socklabs.com> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-html-map-yahoo at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=HTML-Map-Yahoo>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc HTML::Map::Yahoo

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/HTML-Map-Yahoo>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/HTML-Map-Yahoo>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=HTML-Map-Yahoo>

=item * Search CPAN

L<http://search.cpan.org/dist/HTML-Map-Yahoo>

=back

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2006 Nick Gerakines, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
