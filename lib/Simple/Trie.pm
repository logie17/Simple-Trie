package Simple::Trie;
use Moo;
use constant '_END' => '';

# ABSTRACT: Trie, it's simple

has words => (
    is => 'rw',
    initializer => 'words',
    trigger => sub { (shift)->_make_trie(shift) },
    coerce => sub { ref $_[0] eq 'ARRAY' ? $_[0] : [split(/\s/,$_[0])] }
);

has _trie => ( is => 'rw', default => sub {{}} );

sub add { (shift)->_add_node(@_) }

sub find {
    my ($self, $word) = @_;
    my $node = $self->_trie;
    $node = $node->{$_} for split "", $word;
    return exists $node->{_END()} ? 1 : 0;
}

sub smart_find {
    my ($self, $prefix) = @_;
    my @letters = split "", $prefix;
    my $node = $self->_trie;

    $node = $node->{$_} for @letters;

    if ($node) {
        my @found;
        $self->_find_all($prefix, $node, \@found);
        return @found;
    }
    return;
}

sub _add_node {
    my ($self, $word) = @_;
    my $head;
    my $node = $head = $self->_trie;

    my @letters = split "", $word;
    while ( scalar @letters && exists($node->{$letters[0]}) ) {
        $node = $node->{shift(@letters)};
    }
    for my $letter (@letters) {
        $node = $node->{$letter} = {};
    }
    $node->{_END()} = undef;
}

sub _find_all {
    my ($self, $prefix, $node, $found) = @_;
    push @$found, $prefix if exists $node->{_END()};
    $self->_find_all($prefix . $_, $node->{$_}, $found) for keys %$node;
}

sub _make_trie {
    my ($self, $words) = @_;
    $self->_add_node($_) for @$words;
}

=head1 SYNOPSIS

  $trie = Simple::Trie->new(words => [ qw(foo bar food) ] );

  $trie->add('baz');
  say "Found foo" if $trie->find('foo');
  my @results = $trie->smart_find('f');

=head1 DESCRIPTION

  This is an implementation of a Trie, but it's not very sophisticated. This was done
  as a way for myself to become more aquainted with the algorithm described here

  http://en.wikipedia.org/wiki/Trie

=head1 ATTRIBUTES

=head2 words

The current set of words during initializion.

=head1 METHODS

=head2 add($word)

Will add a word to the trie.

=head2 find($word)

Will return true if the word is found in the trie.

=head2 smart_find($letters)

Will return a list of found words that match.

=head1 SEE ALSO

L<Moo> 

=cut

1;
