use strict;
use warnings;
use utf8;
use Lingua::JA::Regular::Unicode qw/hiragana2katakana/;
use File::Basename;
use File::Spec::Functions;
use Encode;


my $file = $ARGV[0];
open my $in, '<:utf8', $file or die $!;
my @text = <$in>;
close $in;

for my $text (@text) {
    chomp($text);
    my @sentence = split( /\n/, $text );
    @sentence = map { &fixText($_) } @sentence;
    $text = join( '', @sentence ) . "\n";
}

my ( $base, $path ) = fileparse($file);
$base = 'Katakana_' . $base;
my $saveas = catfile( $path, $base );

open my $out, '>:utf8', $saveas or die $!;
print {$out} @text;
close $out;


sub fixText {
    my $sentence = shift @_;
	$sentence = hiragana2katakana($sentence);
	
    return $sentence;
}

