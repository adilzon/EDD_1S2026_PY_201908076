package Medicamento;

use strict;
use warnings;

my $contador_medicamentos = 0;

# =========================================
# Crear medicamento (indice automatico)
# =========================================
sub crear {
    my (
        $codigo,
        $nombre,
        $principio,
        $laboratorio,
        $cantidad,
        $vencimiento,
        $precio,
        $minimo
    ) = @_;

    my $self = {
        codigo      => $codigo,
        nombre      => $nombre,
        principio   => $principio,
        laboratorio => $laboratorio,
        cantidad    => $cantidad,
        vencimiento => $vencimiento,
        precio      => $precio,
        minimo      => $minimo,

        indice      => $contador_medicamentos,  # indice automatico (columna matriz)

        siguiente   => undef,
        anterior    => undef,
    };

    $contador_medicamentos++;
    return $self;
}

1;