package Classifier::Filter::Memory;
use strict;
use warnings;
use base qw/Classifier::Filter/;

use Data::Dumper;
use Storable qw(nstore retrieve);


sub new {
    my $class = shift;
    my $self = bless {@_}, $class;

    $self->{term_count} ||= {};
    $self->{category_count} ||= {};

    $self;
}

sub update_count {
    my ($self, $term, $cat, $count) = @_;

    $self->_update_term_count($term, $cat, $count);
    $self->_update_category_count($cat);
}

sub category_count {
    my ($self, $cat) = @_;
    return $self->{category_count}->{$cat};
}

sub term_count {
    my ($self, $term, $cat) = @_;
    return $self->{term_count}->{$term}->{$cat} || 0;
}

sub category_list {
    my $self = shift;
    return keys %{$self->{category_count}};
}

sub total_term_count {
    my $self = shift;

    my $count = 0;
    for my $v (values %{$self->{category_count}}) {
	$count += $v;
    }

    return $count;
}

sub total_category_count {
    my $self = shift;
    my $total = keys %{$self->{category_count}};
    return $total;
}

sub _update_term_count {
    my ($self, $term, $cat, $count) = @_;
    $self->{term_count}->{$term}->{$cat} += $count;
}

sub _update_category_count {
    my ($self, $cat) = @_;
    $self->{category_count}->{$cat} += 1;
}

sub save_filter {
    my ($self, $path) = @_;
    nstore $self, $path;
}

sub load_filter {
    my ($self, $path) = @_;
    return retrieve $path;
}

sub dump {
    my $self = shift;
    warn Data::Dumper::Dumper($self->{term_count}, $self->{category_count});
}

1;
