#! /usr/bin/env perl

use strict;
use warnings;
use Test::More;
use constant '_END' => '';


my $TRIE = { };

sub make_trie {
    my @words = @_;
    for my $word ( @words ) {
        _add_node($word);
    }
    return $TRIE;
}

sub add_to {
    _add_node(@_);
}

sub _add_node {
    my $node = $TRIE;
    my @letters = split "", shift;
    # walk the trie
    while ( scalar @letters && exists($node->{$letters[0]}) ) {
        $node = $node->{shift(@letters)};       
    }
    for my $letter (@letters) {
        $node = $node->{$letter} = {};
    }
    $node->{_END()} = undef;
}

sub find {
    my $word = shift;
    my $node = $TRIE;
    $node = $node->{$_} for split "", $word;
    return exists $node->{_END()} ? 1 : 0;
}

sub _find_all {
    my ($prefix, $node, $found) = @_;
    push @$found, $prefix if exists $node->{_END()};
    _find_all($prefix . $_, $node->{$_}, $found) for keys %$node;
}

sub smart_find {
    my $prefix = shift;
    my @letters = split "", $prefix;
    my $node = $TRIE;

    $node = $node->{$_} for @letters;    

    if ($node) {
        my @found;
        _find_all($prefix, $node, \@found);                
        return @found;
    }
    return;
}

# TODO, interesting prototype make_trie { split /./, shift } @words;

my $trie = make_trie(qw(foo bar food));

is_deeply $trie, {'b' => { 'a' => { 'r' => { '' => undef }}}, 'f' => { 'o' => { 'o' => { '' => undef, 'd' => { '' => undef }}}}}; 
ok find('foo');
ok !find ('unknown');

ok ! find('baz');
add_to('baz');
ok find('baz');

add_to('foe');
my @results = smart_find('f');
is_deeply [sort @results], ['foe', 'foo', 'food' ];
done_testing;
