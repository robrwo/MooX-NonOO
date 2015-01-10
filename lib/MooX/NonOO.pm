package MooX::NonOO;

use strict;
use warnings;

use feature qw/ state /;

use Exporter qw/ import /;

use Package::Stash;
use Scalar::Util qw/ blessed /;

BEGIN {
    require MooX::Singleton;
    no strict 'refs';
    *{'instance'} = \&MooX::Singleton::instance;
}

our @EXPORT = qw/ as_function instance /;

sub as_function {
    my %opts = @_;

    my @args  = @{ $opts{args}    // [] };
    my @names = @{ $opts{methods} // [] };
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
                    state $self = $caller->instance(@args);
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
