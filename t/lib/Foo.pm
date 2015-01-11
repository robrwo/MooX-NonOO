package Foo;

use Moo;
use MooX::NonOO;

has bar => ( is => 'rw', default => 1 );

sub baz {
  my ($self) = shift;
  $self->bar + 1;
}

as_function
  export => [qw/ bar baz /],
  args => [ bar => 5 ];

1;
