use strict;
use warnings;
use DBI;
use Classifier;
use Classifier::Filter::Memory;

my $dat = './filter.dat';

my $cl = Classifier->new;
my $filter = Classifier::Filter::Memory->new();
$cl->set_filter($filter);

# 学習フェーズ
if (-e $dat) {
    $cl->load_filter($dat);
} else {
    $cl->train('perlやpythonはスクリプト言語です', 'it');
    $cl->train('perlでベイジアンフィルタを作りました', 'it');
    $cl->train('pythonはニシキヘビ科のヘビの総称', 'science');
}
$cl->save_filter($dat);


# カテゴリ推定
print $cl->predict('perlは楽しい'),"\n";
print $cl->predict('pythonとperl'),"\n";
print $cl->predict('pythonはヘビ'),"\n";

