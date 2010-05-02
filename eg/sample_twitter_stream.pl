use strict;
use warnings;
use lib './lib';
use utf8;
use FindBin::libs;

use Text::MeCab;
use Classifier;
use Classifier::Filter::DBI;
use Encode;

use Config::Pit;
use AnyEvent::Twitter::Stream;

use DBI;
use DBIx::Class;


my ($username, $password) = do { @{ Config::Pit::get( 'twitter.com', require => {
    'username' => 'memememomo', })}{ qw/username password/ }; 
};


my $cl = Classifier->new;
my $cl_filter = Classifier::Filter::DBI->new(dbh => DBI->connect('dbi:mysql:classifier','root',''));
$cl->set_filter($cl_filter);


my $c = AnyEvent->condvar;

my $stream; $stream = AnyEvent::Twitter::Stream->new(
    username => $username,
    password => $password,
    method => 'sample',
    on_tweet => sub {
	my $tweet = shift;
	my $text = $tweet->{text};

	my $lang = $tweet->{user}{lang};
	return '' if(! $lang || $lang ne 'ja' || ! $text);

	if ($text =~ m/\#([a-zA-Z0-9]+)[^a-zA-Z0-9]?/) {
	    my $cat = $1;
	    while ($text =~ m/\#([a-zA-Z0-9]+)[^a-zA-Z0-9]?/g) {
		my $c = $1;
		$cl->train($text, $c);
	    }
	    my $p = "カテゴリ: $cat -> " . $text;
	    print encode('utf8', $p), "\n";
	} else {
	    my $p = sprintf("推定カテゴリ: %s -> ", $cl->predict($text)) . $text;
	    print encode('utf8', $p), "\n";
	}
    },
    on_error => sub {
	my $error = shift;
	warn "ERROR: $error";
    },
    on_eof => sub {

    },
    );

$c->recv;
