package Classifier::Util;
use strict;
use warnings;
use Text::MeCab;

sub text2vec {
    my ($text) = @_;

    my $vec = {};
    my $mecab = Text::MeCab->new;
    for (my $node = $mecab->parse($text); $node; $node = $node->next) {
	if ($node->posid =~ m/^(?:1|2|3|4)$/) {
	    $vec->{$node->surface}++;
	}
    }
    return $vec;
}

1;
