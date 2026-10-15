use strict;
use warnings;

my $svg = do { local $/; <> };

$svg =~ s/<g\b(?=[^>]*\bid="page1")/<g fill="#ffffff"/
    or die "no <g id=\"page1\"> around the glyphs in $ARGV\n";

print $svg;
