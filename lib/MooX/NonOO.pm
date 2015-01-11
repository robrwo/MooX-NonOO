package MooX::NonOO;

# ABSTRACT: Use Moo methods as functions with an implicit singleton

use strict;
use warnings;

use feature qw/ state /;

use Exporter qw/ import /;
use Package::Stash;
use Scalar::Util qw/ blessed /;

{
    use version;
    $MooX::NonOO::VERSION = version->declare('v0.1.0');
}

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

=begin :readme

=head1 INSTALLATION

See
L<How to install CPAN modules|http://www.cpan.org/modules/INSTALL.html>.

=for readme plugin requires heading-level=2 title="Required Modules"

=for readme plugin changes

=end :readme

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

=head1 AUTHOR

Robert Rothenberg, C<< <rrwo at cpan.org> >>

=head2 Acknowledgements

Several people who pointed out that this module is unnecessary.
(Yes, it's written to scratch an itch.)

=head1 LICENSE AND COPYRIGHT

Copyright 2015 Robert Rothenberg.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

=for readme stop

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=for readme continue

=cut

1;
