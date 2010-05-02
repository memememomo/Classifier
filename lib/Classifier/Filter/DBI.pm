package Classifier::Filter::DBI;
use strict;
use warnings;
use base qw/Classifier::Filter/;

my @dbh_list;

sub new {
    my $class = shift;
    bless { @_ }, $class;
}

sub set_handle {
    my ($self, $handle) = @_;
    push @dbh_list, $handle;
    $self->{dbh} = $handle;
    $self;
}

sub update_count {
    my ($self, $term, $cat, $count) = @_;
    
    $self->_update_term_count($term, $cat, $count);
    $self->_update_category_count($cat);
}

sub total_category_count {
    my $self = shift;
    
    my $sth = $self->{dbh}->prepare("SELECT COUNT(id) FROM category_count");
    $sth->execute();
    my $total = $sth->fetchrow || 0;
    $sth->finish;
    undef $sth;

    return $total;
}

sub total_term_count {
    my $self = shift;
    
    my $sth = $self->{dbh}->prepare("SELECT SUM(count) FROM category_count");
    $sth->execute();
    my $count = $sth->fetchrow;
    $sth->finish;
    undef $sth;

    return $count;
}

sub category_count {
    my ($self, $cat) = @_;

    my $sth = $self->{dbh}->prepare("SELECT count FROM category_count WHERE category = ?");
    $sth->execute($cat);
    my $count = $sth->fetchrow || 0;
    $sth->finish;
    undef $sth;

    return $count;
}

sub term_count {
    my ($self, $term, $cat) = @_;
    
    my $sth = $self->{dbh}->prepare("SELECT count FROM term_count WHERE term = ? AND category = ?");
    $sth->execute($term, $cat);
    my $count = $sth->fetchrow || 0;
    $sth->finish;
    undef $sth;

    return $count;
}

sub category_list {
    my $self = shift;

    my $sth = $self->{dbh}->prepare("SELECT category FROM category_count");
    $sth->execute();
    my @category_list = ();
    while (my $category = $sth->fetchrow) {
	push @category_list, $category;
    }
    $sth->finish;
    undef $sth;

    return @category_list;
}

sub _update_term_count {
    my ($self, $term, $cat, $count) = @_;

    my $dbh = $self->{dbh};

    my $sth = $dbh->prepare("SELECT count FROM term_count WHERE term = ? AND category = ?");
    $sth->execute($term, $cat);
    my $count_term = $sth->fetchrow || 0;
    $sth->finish;
    undef $sth;

    if ($count_term) {
	$count_term += $count;
	my $update = $dbh->prepare("UPDATE term_count SET count = ? WHERE term = ? AND category = ?");
	$update->execute($count, $term, $cat);
	$update->finish;
	undef $update;
    } else {
	$count_term += $count;
	my $insert = $dbh->prepare("INSERT INTO term_count (term, category, count) VALUES (?,?,?)");
	$insert->execute($term, $cat, $count_term);
	$insert->finish;
	undef $insert;
    }
}

sub _update_category_count {
    my ($self, $cat) = @_;
    
    my $dbh = $self->{dbh};
    
    my $sth = $dbh->prepare("SELECT count FROM category_count WHERE category = ?");
    $sth->execute($cat);
    my $count_cat = $sth->fetchrow || 0;
    $sth->finish;
    undef $sth;

    if ($count_cat) {
	$count_cat += 1;
	my $update = $dbh->prepare("UPDATE category_count SET count = ? WHERE category = ?");
	$update->execute($count_cat, $cat);
	$update->finish;
	undef $update;
    } else {
	$count_cat += 1;
	my $insert = $dbh->prepare("INSERT INTO category_count (category, count) VALUES (?,?)");
	$insert->execute($cat, $count_cat);
	$insert->finish;
	undef $insert;
    }
}

END { 
    for my $dbh (@dbh_list) {
	$dbh->disconnect;
    }
};

1;
