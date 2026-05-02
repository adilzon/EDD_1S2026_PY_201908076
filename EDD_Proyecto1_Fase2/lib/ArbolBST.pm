#!/usr/bin/perl
use strict;
use warnings;

package ArbolBST;

# ====================== CONSTRUCTOR ======================
sub new {
    my $class = shift;
    my $self = {
        raiz => undef
    };
    bless $self, $class;
    return $self;
}

# ====================== INSERTAR ======================
sub insertar {
    my ($self, $nodo) = @_;
    $self->{raiz} = _insertar_rec($self->{raiz}, $nodo);
}

# Método cómodo para registrar desde el formulario GTK
sub insertar_desde_datos {
    my ($self, $codigo, $nombre, $fabricante, $precio, $cantidad, $fecha_ingreso, $nivel_minimo) = @_;

    use NodoEquipo;  # Aseguramos que esté cargado

    my $nuevo = NodoEquipo->new(
        $codigo, 
        $nombre, 
        $fabricante || 'Sin fabricante',
        $precio || 0,
        $cantidad || 0,
        $fecha_ingreso || '2026-04-11',
        $nivel_minimo || 1
    );

    $self->insertar($nuevo);
}

sub _insertar_rec {
    my ($actual, $nuevo) = @_;

    # Caso base: si el subárbol está vacío, devolvemos el nuevo nodo
    return $nuevo unless defined $actual;

    my $cod_nuevo  = $nuevo->obtener_codigo;
    my $cod_actual = $actual->obtener_codigo;

    if ($cod_nuevo lt $cod_actual) {
        $actual->{izquierda} = _insertar_rec($actual->{izquierda}, $nuevo);
    } 
    elsif ($cod_nuevo gt $cod_actual) {
        $actual->{derecha} = _insertar_rec($actual->{derecha}, $nuevo);
    } 
    else {
        # Código duplicado
        die "Error: Ya existe un equipo con el código '$cod_nuevo'.";
        # O si prefieres solo advertir sin detener:
        # warn "Advertencia: El equipo con código '$cod_nuevo' ya existe.\n";
        # return $actual;
    }

    return $actual;          # ← ESTA LÍNEA ERA LA QUE FALTABA
}

# ====================== BUSCAR ======================
sub buscar {
    my ($self, $codigo) = @_;
    return _buscar_rec($self->{raiz}, $codigo);
}

sub _buscar_rec {
    my ($actual, $codigo) = @_;
    return undef unless defined $actual;

    if ($codigo eq $actual->obtener_codigo) {
        return $actual;
    } 
    elsif ($codigo lt $actual->obtener_codigo) {
        return _buscar_rec($actual->{izquierda}, $codigo);
    } 
    else {
        return _buscar_rec($actual->{derecha}, $codigo);
    }
}

# ====================== ELIMINAR ======================
sub eliminar {
    my ($self, $codigo) = @_;
    $self->{raiz} = _eliminar_rec($self->{raiz}, $codigo);
}

sub _eliminar_rec {
    my ($actual, $codigo) = @_;
    return undef unless defined $actual;

    if ($codigo lt $actual->obtener_codigo) {
        $actual->{izquierda} = _eliminar_rec($actual->{izquierda}, $codigo);
    } 
    elsif ($codigo gt $actual->obtener_codigo) {
        $actual->{derecha} = _eliminar_rec($actual->{derecha}, $codigo);
    } 
    else {
        # Caso 1: Hoja (sin hijos)
        return undef if (!defined $actual->{izquierda} && !defined $actual->{derecha});

        # Caso 2: Un solo hijo
        if (!defined $actual->{izquierda}) {
            return $actual->{derecha};
        }
        if (!defined $actual->{derecha}) {
            return $actual->{izquierda};
        }

        # Caso 3: Dos hijos - usar sucesor in-order
        my $sucesor = _minimo_valor_nodo($actual->{derecha});

        # Copiar datos del sucesor al nodo actual
        $actual->{codigo}          = $sucesor->obtener_codigo;
        $actual->{nombre}          = $sucesor->obtener_nombre;
        $actual->{fabricante}      = $sucesor->obtener_fabricante;
        $actual->{precio_unitario} = $sucesor->obtener_precio;
        $actual->{cantidad}        = $sucesor->obtener_cantidad;
        $actual->{fecha_ingreso}   = $sucesor->obtener_fecha_ingreso;
        $actual->{nivel_minimo}    = $sucesor->obtener_nivel_minimo;

        # Eliminar el sucesor
        $actual->{derecha} = _eliminar_rec($actual->{derecha}, $sucesor->obtener_codigo);
    }
    return $actual;
}

sub _minimo_valor_nodo {
    my $nodo = shift;
    while (defined $nodo && defined $nodo->{izquierda}) {
        $nodo = $nodo->{izquierda};
    }
    return $nodo;
}

# ====================== RECORRIDOS (para consola - opcional) ======================
sub pre_orden  { my $self = shift; _pre_orden_rec($self->{raiz}); }
sub in_orden   { my $self = shift; _in_orden_rec($self->{raiz}); }
sub post_orden { my $self = shift; _post_orden_rec($self->{raiz}); }

sub _pre_orden_rec {
    my $nodo = shift;
    return unless defined $nodo;
    print_equipo($nodo);
    _pre_orden_rec($nodo->{izquierda});
    _pre_orden_rec($nodo->{derecha});
}

sub _in_orden_rec {
    my $nodo = shift;
    return unless defined $nodo;
    _in_orden_rec($nodo->{izquierda});
    print_equipo($nodo);
    _in_orden_rec($nodo->{derecha});
}

sub _post_orden_rec {
    my $nodo = shift;
    return unless defined $nodo;
    _post_orden_rec($nodo->{izquierda});
    _post_orden_rec($nodo->{derecha});
    print_equipo($nodo);
}

sub print_equipo {
    my $n = shift;
    printf "%-10s | %-30s | %-20s | Q%-8.2f | %-6d | %s | Min: %d\n",
           $n->obtener_codigo, 
           $n->obtener_nombre, 
           $n->obtener_fabricante,
           $n->obtener_precio, 
           $n->obtener_cantidad,
           $n->obtener_fecha_ingreso, 
           $n->obtener_nivel_minimo;
}

# ====================== GRAPHVIZ ======================
sub generar_dot {
    my ($self, $filename) = @_;

    open my $fh, '>', $filename or die "No se pudo crear $filename: $!";

    print $fh "digraph BST_Equipos {\n";
    print $fh "    rankdir=TB;\n";
    print $fh "    node [shape=box, style=filled, fontname=\"Arial\"];\n\n";

    my $raiz = $self->{raiz};

    if (!defined $raiz) {
        print $fh "    empty [label=\"Arbol vacio\"];\n";
    } else {
        _generar_dot_rec_mejorado($raiz, $fh, 1);
    }

    print $fh "}\n";
    close $fh;
}

sub _generar_dot_rec_mejorado {
    my ($nodo, $fh, $es_raiz) = @_;
    return unless defined $nodo;

    my $id = $nodo->obtener_codigo;

    my $vida_util = $nodo->obtener_fecha_ingreso // "N/A";

    my $label = "Codigo: $id\\n" .
                "Nombre: " . $nodo->obtener_nombre . "\\n" .
                "Marca: " . $nodo->obtener_fabricante . "\\n" .
                "Cantidad: " . $nodo->obtener_cantidad . "\\n" .
                "Vida util: $vida_util";

    my $color = "lightblue";

    if ($es_raiz) {
        $color = "gold";
    }
    elsif (!defined $nodo->{izquierda} && !defined $nodo->{derecha}) {
        $color = "lightgreen";
    }

    print $fh "    \"$id\" [style=filled, fillcolor=$color, label=\"$label\"];\n";

    # IZQUIERDA
    if (defined $nodo->{izquierda}) {
        my $izq = $nodo->{izquierda}->obtener_codigo;
        print $fh "    \"$id\" -> \"$izq\" [color=red, label=\"Menor\"];\n";
        _generar_dot_rec_mejorado($nodo->{izquierda}, $fh, 0);
    }

    # DERECHA
    if (defined $nodo->{derecha}) {
        my $der = $nodo->{derecha}->obtener_codigo;
        print $fh "    \"$id\" -> \"$der\" [color=blue, label=\"Mayor\"];\n";
        _generar_dot_rec_mejorado($nodo->{derecha}, $fh, 0);
    }
}

# ====================== OBTENER RAÍZ (útil para depuración) ======================
sub obtener_raiz {
    my $self = shift;
    return $self->{raiz};
}

1;