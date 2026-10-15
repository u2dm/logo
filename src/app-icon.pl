use strict;
use warnings;
use List::Util qw(pairs);

use constant {
    LOGO_SCALE          => 0.8,
    CORNER_RADIUS_RATIO => 0.225,
    BAND_HEIGHT_RATIO   => 0.1,
};

my @PRIDE_FLAG_COLORS = ('#e40303', '#ff8c00', '#ffed00', '#008026', '#24408e', '#732982');

my $svg = do { local $/; <> };

my ($logo_x, $logo_y, $logo_size) = $svg =~ /viewBox="([-\d.]+) ([-\d.]+) ([-\d.]+) [-\d.]+"/
    or die "no viewBox in $ARGV\n";

my $icon_size = $logo_size / LOGO_SCALE;
my $padding = ($icon_size - $logo_size) / 2;
my $icon_x = $logo_x - $padding;
my $icon_y = $logo_y - $padding;
my $icon_right = $icon_x + $icon_size;
my $corner_radius = $icon_size * CORNER_RADIUS_RATIO;
my $band_height = $icon_size * BAND_HEIGHT_RATIO;
my $stripe_width = $icon_size / @PRIDE_FLAG_COLORS;

my $icon_shape = rect(
    x      => $icon_x,
    y      => $icon_y,
    width  => $icon_size,
    height => $icon_size,
    rx     => $corner_radius,
    ry     => $corner_radius,
    fill   => '#ffffff',
);

my $stripes = join "\n    ", map {
    my $stripe_left = $icon_x + $_ * $stripe_width;
    rect(
        x      => $stripe_left,
        y      => $icon_y,
        width  => $icon_right - $stripe_left,
        height => $icon_size,
        fill   => $PRIDE_FLAG_COLORS[$_],
    );
} 0 .. $#PRIDE_FLAG_COLORS;

my $white_middle = rect(
    x      => $icon_x,
    y      => $icon_y + $band_height,
    width  => $icon_size,
    height => $icon_size - 2 * $band_height,
    fill   => '#ffffff',
);

$svg =~ s/viewBox="[^"]*"/viewBox="$icon_x $icon_y $icon_size $icon_size"/;
$svg =~ s/width="[^"]*"/width="${icon_size}pt"/;
$svg =~ s/height="[^"]*"/height="${icon_size}pt"/;
$svg =~ s{(<svg\b[^>]*>)}{$1
  <mask id="icon-shape">
    $icon_shape
  </mask>
  <g mask="url(#icon-shape)">
    $stripes
    $white_middle
  </g>};

print $svg;

sub rect {
    my $attributes = join ' ', map { sprintf '%s="%s"', @$_ } pairs @_;
    return "<rect $attributes/>";
}
