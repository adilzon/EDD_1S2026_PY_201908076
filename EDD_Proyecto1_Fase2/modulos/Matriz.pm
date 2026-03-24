package Matriz;

use strict;
use warnings;

# --- 1. Nodo de la Matriz ---
sub nuevo_nodo {
    my ($fila, $columna, $detalle) = @_;
    return {
        fila    => $fila,    # Ej: ID del Médico
        columna => $columna, # Ej: Fecha de la cita
        detalle => $detalle, # La información de la cita
        derecha => undef,
        izquierda => undef,
        arriba  => undef,
        abajo   => undef
    };
}

# --- 2. Cabeceras (Headers) ---
sub nueva_cabecera {
    my ($id) = @_;
    return {
        id    => $id,
        sig   => undef,
        ant   => undef,
        acceso => undef # Puntero al primer nodo real de esa fila/columna
    };
}

1;