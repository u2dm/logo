use strict;
use warnings;
use List::Util qw(max);

my $svg = do { local $/; <> };

my ($x, $y, $width, $height) = $svg =~ /viewBox="([-\d.]+) ([-\d.]+) ([-\d.]+) ([-\d.]+)"/
    or die "no viewBox in $ARGV\n";

my $side = max($width, $height);
my $square_x = $x - ($side - $width) / 2;
my $square_y = $y - ($side - $height) / 2;

$svg =~ s/viewBox="[^"]*"/viewBox="$square_x $square_y $side $side"/;
$svg =~ s/width="[^"]*"/width="${side}pt"/;
$svg =~ s/height="[^"]*"/height="${side}pt"/;

print $svg;
