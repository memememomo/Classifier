use strict;
use warnings;
use DBI;
use Classifier;
use Classifier::Filter::DBI;

my $cl = Classifier->new;
my $filter = Classifier::Filter::DBI->new( dbh => DBI->connect('dbi:mysql:classifier','root',''));
$cl->set_filter($filter);

# 学習フェーズ
$cl->train('perlやpythonはスクリプト言語です'), 'it');
$cl->train('perlでベイジアンフィルタを作りました'), 'it');
$cl->train('pythonはニシキヘビ科のヘビの総称'), 'science');

# カテゴリ推定
print $cl->predict('perlは楽しい')."¥n";
print $cl->predict('pythonとperl')."¥n";
print $cl->predict('pythonはヘビ')."¥n";
