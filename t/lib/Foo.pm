package Foo;

use Moo;
use MooX::NonOO;

has bar => ( is => 'rw', default => 1 );

sub baz {
  my ($self) = shift;
  $self->bar + 1;
}

sub boop {
  my ($self) = shift;
  return ( $self->bar, $self->baz );
}

as_function
  export => [qw/ bar baz boop /],
  args => [ bar => 5 ];

1;
