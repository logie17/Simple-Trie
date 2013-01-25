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
    my @letters = (shift) =~ /./g;
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
    $node = $node->{$_} for $word =~ /./g;
    return exists $node->{_END()} ? 1 : 0;
}

# TODO, interesting prototype make_trie { split /./, shift } @words;

my $trie = make_trie(qw(foo bar food));

is_deeply $trie, {'b' => { 'a' => { 'r' => { '' => undef }}}, 'f' => { 'o' => { 'o' => { '' => undef, 'd' => { '' => undef }}}}}; 
ok find('foo');
ok !find ('unknown');

ok ! find('baz');
add_to('baz');
ok find('baz');

done_testing;
