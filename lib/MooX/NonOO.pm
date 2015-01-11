package MooX::NonOO;

# ABSTRACT: Use Moo methods as functions with an implicit singleton

use strict;
use warnings;

use feature qw/ state /;

use Exporter qw/ import /;
use Package::Stash;
use Scalar::Util qw/ blessed /;

# RECOMMEND PREREQ: Package::Stash::XS 0

=head1 NAME

MooX::NonOO - Use Moo methods as functions with an implicit singleton

=head1 SYNOPSYS

In a module:

  package MyModule;

  use Moo;
  use MooX::NonOO;

  ...

  sub my_method {
     my ($self, @args) = @_;
     ...
  }

  as_function
    export => [ 'my_method' ], # methods to export
    args   => [ ];             # constructor args

The module can be be used with a function calling style:

  use MyModule;

  ...

  my_method(@args);

=head1 DESCRIPTION

This module allows you to turn a class into a module that exports
methods as functions that use an implicit singleton.

=head1 EXPORTS

=head2 C<as_function>

  as_function
    exports => \@methods,
    args    => \@args;

This wraps methods in a function that checks the first argument. If
the argument is an instance of the class, then it assumes it is a
normal method call.  Otherwise it assumes it is a function call, and
it calls the method with the singleton instance.

Note that this will not work properly on methods that take an instance
of the class as the first argument.

=cut

our @EXPORT = qw/ as_function _MooX_NonOO_instance /;

sub _MooX_NonOO_instance {
    my $class = shift;
    state $symbol = '$_MooX_NonOO';
    my $stash = Package::Stash->new($class);
    if (my $instance = $stash->get_symbol($symbol)) {
      return ${$instance};
    } else {
      my $instance = $class->new(@_);
      $stash->add_symbol($symbol, \$instance);
      return $instance;
    }
}

sub as_function {
    my %opts = @_;

    my @args  = @{ $opts{args}    // [] };
    my @names = @{ $opts{export} // [] };
    foreach my $name (@names) {

        my ($caller) = caller;
        my $stash = Package::Stash->new($caller);

        $stash->add_symbol( '&import', \&Exporter::import );

        my $symbol = '&' . $name;
        if ( my $method = $stash->get_symbol($symbol) ) {

            my $export    = $stash->get_or_add_symbol('@EXPORT');
            my $export_ok = $stash->get_or_add_symbol('@EXPORT_OK');

            my $new = sub {
                if ( blessed( $_[0] ) && $_[0]->isa($caller) ) {
                    return $method->(@_);
                }
                else {
                    state $self = $caller->_MooX_NonOO_instance(@args);
                    return $self->$method(@_);
                }
            };
            $stash->add_symbol( $symbol, $new );

            push @{$export},    $name;
            push @{$export_ok}, $name;
        }
        else {
            die "No method named ${name}";
        }
    }
}

1;
