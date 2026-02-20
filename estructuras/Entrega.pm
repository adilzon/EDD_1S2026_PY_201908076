package Entrega;

use strict;
use warnings;

# =========================================
# Crear nodo de entrega
# =========================================
sub crear {
    my ($fecha, $factura, $medicamento, $cantidad) = @_;

    my $self = {
        fecha       => $fecha,
        factura     => $factura,
        medicamento => $medicamento,
        cantidad    => $cantidad,
        siguiente   => undef,   # lista simple de entregas
    };

    return $self;
}

1;
