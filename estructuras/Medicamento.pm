package Medicamento;

use strict;
use warnings;

sub crear {
    my ($codigo, $nombre, $principio, $laboratorio, $cantidad, $vencimiento, $precio, $minimo) = @_;

    return {
        codigo      => $codigo,
        nombre      => $nombre,
        principio   => $principio,
        laboratorio => $laboratorio,
        cantidad    => $cantidad,
        vencimiento => $vencimiento,
        precio      => $precio,
        minimo      => $minimo,
        siguiente   => undef,
        anterior    => undef,
    };
}

1;
