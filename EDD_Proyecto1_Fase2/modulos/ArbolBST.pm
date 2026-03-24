package ArbolBST;

use strict;
use warnings;

# --- 1. Crear un Nodo de Equipo ---
sub nuevo_nodo {
    my ($codigo, $nombre, $fabricante, $precio, $cantidad) = @_;
    return {
        codigo     => $codigo,
        nombre     => $nombre,
        fabricante => $fabricante,
        precio     => $precio,
        cantidad   => $cantidad,
        izq        => undef, # Hijo izquierdo
        der        => undef  # Hijo derecho
    };
}

# --- 2. Insertar en el Árbol ---
sub insertar {
    my ($raiz, $nuevo_nodo) = @_;

    # Si el árbol está vacío, el nuevo nodo es la raíz
    if (!defined($raiz)) {
        return $nuevo_nodo;
    }

    # Comparamos códigos alfabéticamente (usamos 'lt' para menor y 'gt' para mayor en Perl)
    if ($nuevo_nodo->{codigo} lt $raiz->{codigo}) {
        $raiz->{izq} = insertar($raiz->{izq}, $nuevo_nodo);
    } elsif ($nuevo_nodo->{codigo} gt $raiz->{codigo}) {
        $raiz->{der} = insertar($raiz->{der}, $nuevo_nodo);
    }
    
    return $raiz;
}

# --- 3. Buscar en el Árbol ---
sub buscar {
    my ($raiz, $codigo_buscado) = @_;

    if (!defined($raiz)) {
        return undef; # No encontrado
    }

    if ($codigo_buscado eq $raiz->{codigo}) {
        return $raiz; # ¡Lo encontramos!
    } elsif ($codigo_buscado lt $raiz->{codigo}) {
        return buscar($raiz->{izq}, $codigo_buscado);
    } else {
        return buscar($raiz->{der}, $codigo_buscado);
    }
}
