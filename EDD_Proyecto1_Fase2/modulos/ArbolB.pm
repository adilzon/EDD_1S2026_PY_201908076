package ArbolB;

use strict;
use warnings;

# --- 1. Crear un Nodo del Árbol B ---
sub nuevo_nodo {
    my ($es_hoja) = @_;
    return {
        claves  => [],    # Lista de suministros en este nodo (máximo 3)
        hijos   => [],    # Referencias a otros nodos (máximo 4)
        es_hoja => $es_hoja,
        n       => 0      # Contador de cuántas claves tiene actualmente
    };
}

# --- 2. Estructura del Suministro ---
sub nuevo_suministro {
    my ($codigo, $nombre, $precio, $cantidad) = @_;
    return {
        codigo   => $codigo,
        nombre   => $nombre,
        precio   => $precio,
        cantidad => $cantidad
    };
}

