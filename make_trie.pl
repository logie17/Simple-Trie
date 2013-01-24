#! /usr/bin/env perl

use strict;
use warnings;

my $TRIE = { };

sub make_trie {
    my @words = @_;
    for my $word ( @words ) {
        my $node = $TRIE;
        my @letters = $word =~ /./g;
        # walk the trie
        while ( scalar @letters && exists($node->{$letters[0]}) ) {
            $node = $node->{shift(@letters)};       
        }
        for my $letter (@letters) {
            $node = $node->{$letter} = {};
        }
        $node->{""} = undef;
    }
    return $TRIE;
}

