use strict;
use warnings;

use utf8;
use Encode;
use Net::Twitter::Lite;
use Config::Pit;

use lib './lib';
use Classifier;
use Classifier::Filter::DBI;

use DBI;

my ($username, $password) = do { @{ Config::Pit::get( 'twitter.com', require => {
    'username' => 'memememomo', })}{ qw/username password/ };
};

my $twit = Net::Twitter::Lite->new(username => $username, $password => $password);

my $dbh = DBI->connect('dbi:mysql:classifier','root','');

my $cl = Classifier->new;
my $cl_filter = Classifier::Filter::DBI->new( dbh => $dbh );
$cl->set_filter($cl_filter);


my $sth = $dbh->prepare("SELECT category FROM category_count");
$sth->execute();
while (my $category = $sth->fetchrow) {
    print "$category\n";
    search_tag($category);
}
$sth->finish;
undef $sth;
$dbh->disconnect;


sub search_tag {
    my $tag = shift;

    my $response = $twit->search({ q => '#'.$tag, lang => 'ja' });

    my $count = @{$response->{results}};
    for my $result ( reverse( @{$response->{results}} ) ) {
	my $text = Encode::encode('utf8', $result->{text});
	$cl->train($text, $tag);
    }
}
