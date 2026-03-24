package Entrega;

use strict;
use warnings;

# =========================================
# Crear nodo de entrega
# =========================================
sub crear {
    my ($fecha, $factura, $medicamento, $cantidad, $precio, $medicamento_idx) = @_;

    my $self = {
        fecha           => $fecha,
        factura         => $factura,
        medicamento     => $medicamento,
        cantidad        => $cantidad,
        precio          => $precio,           # Precio de esta entrega
        medicamento_idx => $medicamento_idx,  # Índice del medicamento (matriz)
        siguiente       => undef,              # Lista simple de entregas
    };

    return $self;
}

1;