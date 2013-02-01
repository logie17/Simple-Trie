package Simple::Trie;
use Moo;
use constant '_END' => '';

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
    for my $word ( @$words ) {
        $self->_add_node($word);
    }
}

1;
