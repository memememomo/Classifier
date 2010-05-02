package Classifier;
use strict;
use warnings;
use Classifier::Util;


sub new {
    my $class = shift;
    my $self = bless {@_}, $class;

    return $self;
}

sub set_filter {
    my ($self, $filter) = @_;
    $self->{filter} = $filter;
}
 
sub load_filter {
    my ($self, $handle) = @_;

    if ($handle) {
	if (ref($handle) eq 'DBI::db') {
	    require('Classifier/Filter/DBI.pm');
	    $self->{filter} = Classifier::Filter::DBI->new(dbh => $handle);
	}
    } else {
	require('Classifier/Filter/Memory.pm');
	$self->{filter} = Classifier::Filter::Memory->new();
    }
}

sub train {
    my ($self, $doc, $cat) = @_;
    my $vec = Classifier::Util::text2vec($doc);
    $self->{filter}->train($vec, $cat);
}

sub cat_prob {
    my ($self, $cat) = @_;
    my $total = $self->{filter}->total_term_count();
    return $self->{filter}->category_count($cat) / $total;
}

sub term_prob {
    my ($self, $term, $cat) = @_;
    return $self->{filter}->term_count($term, $cat) / $self->{filter}->category_count($cat);
}

sub predict {
    my ($self, $doc) = @_;

    my $vec = Classifier::Util::text2vec($doc);

    my %scores;
    for my $cat ($self->{filter}->category_list()) {
	$scores{$cat} = $self->score($vec, $cat);
    }
    my @classes = sort { $scores{$b} <=> $scores{$a} } keys %scores;
    return $classes[0];
}

sub score {
    my ($self, $vec, $cat) = @_;
    my $cat_prob = log( $self->cat_prob($cat) );
    my $not_likely = 1 / ($self->{filter}->total_term_count() * 10);

    my $doc_prob = 0;
    while (my ($term, $count) = each %$vec) {
	$doc_prob += log($self->term_prob($term, $cat) || $not_likely) * $count;
    }
    return $cat_prob + $doc_prob;
}

1;
