package Classifier::Filter;
use strict;
use warnings;

sub new {
    my $class = shift;
    bless {@_}, $class;
}

sub train {
    my ($self, $vec, $cat) = @_;

    while (my ($term, $count) = each %$vec) {
	$self->update_count($term, $cat, $count);
    }
}

sub save_filter {}

sub load_filter {}

sub update_count {}

sub dump {}

1;
