package FooGlobal;

use Class::NonOO;

sub new {
    my $class = shift;
    my $self  = {@_};
    $self->{bar} //= 1;
    bless $self, $class;
    return $self;
}

sub bar {
    my ( $self, $val ) = @_;
    if ( defined $val ) {
        $self->{bar} = $val;
    }
    else {
        $self->{bar};
    }
}

sub baz {
    my ($self) = @_;
    $self->bar + 1;
}

sub boop {
    my ($self) = @_;
    return ( $self->bar, $self->baz );
}

as_function
  global    => 1,
  export    => [qw/ bar baz /],
  export_ok => [qw/ boop /],
  args      => [ bar => 5 ];

1;
