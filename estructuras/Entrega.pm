package Entrega;

use strict;
use warnings;

sub crear {
    my ($codigo, $fecha, $cantidad) = @_;

    my $self = {
        codigo    => $codigo,
        fecha     => $fecha,
        cantidad  => $cantidad,
        siguiente => undef,
    };

    return $self;
}

1;
