use strict;
use warnings;
use utf8;
use Lingua::JA::Moji 'kana2romaji';
use File::Basename;
use File::Spec::Functions;
use Encode;


my $file = $ARGV[0];
open my $in, '<:utf8', $file or die $!;
my @text = <$in>;
close $in;

for my $text (@text) {
    chomp($text);
    my @sentence = split( '。', $text );
    @sentence = map { &fixText($_) } @sentence;
    $text = join( '', @sentence ) . "\n";
}

my ( $base, $path ) = fileparse($file);
$base = 'Romaji.txt';
my $saveas = catfile( $path, $base );

open my $out, '>:utf8', $saveas or die $!;
print {$out} @text;
close $out;


sub fixText {
    my $sentence = shift @_;
    $sentence =~ s{([^\x01-\x7E])([\x01-\x7E])}{$1 $2}g;
    $sentence =~ s{([\x01-\x7E])([^\x01-\x7E])}{$1 $2}g;
    $sentence =~ s{、}{, }g;
    $sentence =~ s{・・・}{..}g;
    my $romaji = kana2romaji( $sentence, { style => "hepburn" } );
    $romaji = ucfirst( $romaji . ". " );
    
    return $romaji;
}

