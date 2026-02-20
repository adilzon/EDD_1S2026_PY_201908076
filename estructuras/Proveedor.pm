package Proveedor;

use strict;
use warnings;

# =========================================
# Crear proveedor (nodo de lista circular)
# =========================================
sub crear {
    my ($codigo, $nombre, $telefono) = @_;

    my $self = {
        codigo    => $codigo,     # (NIT o código del proveedor)
        nombre    => $nombre,
        telefono  => $telefono,
        siguiente => undef,
        anterior  => undef,       # NECESARIO para lista circular
        entregas  => undef,       # cabeza de lista de entregas
    };

    return $self;
}

# =========================================
# Agregar entrega al proveedor
# (lista simple de entregas)
# =========================================
sub agregar_entrega {
    my ($proveedor, $entrega) = @_;

    if (!defined $proveedor->{entregas}) {
        $proveedor->{entregas} = $entrega;
    } else {
        my $actual = $proveedor->{entregas};
        while ($actual->{siguiente}) {
            $actual = $actual->{siguiente};
        }
        $actual->{siguiente} = $entrega;
    }
}

1;