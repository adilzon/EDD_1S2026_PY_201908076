#!/usr/bin/perl
use strict;
use warnings;
use lib '.';
use NodoPersonal;

package ArbolAVL;

sub new {
    my $class = shift;
    my $self = { raiz => undef };
    bless $self, $class;
    return $self;
}

# ====================== ALTURA Y BALANCE ======================
sub _altura {
    my $nodo = shift;
    return 0 unless defined $nodo;
    return $nodo->{altura};
}

sub _balance {
    my $nodo = shift;
    return 0 unless defined $nodo;
    return _altura($nodo->{izquierda}) - _altura($nodo->{derecha});
}

sub _actualizar_altura {
    my $nodo = shift;
    return unless defined $nodo;
    $nodo->{altura} = 1 + (_altura($nodo->{izquierda}) > _altura($nodo->{derecha}) 
                          ? _altura($nodo->{izquierda}) 
                          : _altura($nodo->{derecha}));
}

# ====================== ROTACIONES ======================
sub _rotar_derecha {
    my $y = shift;
    my $x = $y->{izquierda};
    my $t2 = $x->{derecha};

    $x->{derecha} = $y;
    $y->{izquierda} = $t2;

    _actualizar_altura($y);
    _actualizar_altura($x);
    return $x;
}

sub _rotar_izquierda {
    my $x = shift;
    my $y = $x->{derecha};
    my $t2 = $y->{izquierda};

    $y->{izquierda} = $x;
    $x->{derecha} = $t2;

    _actualizar_altura($x);
    _actualizar_altura($y);
    return $y;
}

# ====================== INSERTAR ======================
sub insertar {
    my ($self, $nodo) = @_;
    $self->{raiz} = _insertar_rec($self->{raiz}, $nodo);
}

sub _insertar_rec {
    my ($actual, $nuevo) = @_;
    return $nuevo unless defined $actual;

    if ($nuevo->obtener_numero_colegio lt $actual->obtener_numero_colegio) {
        $actual->{izquierda} = _insertar_rec($actual->{izquierda}, $nuevo);
    } elsif ($nuevo->obtener_numero_colegio gt $actual->obtener_numero_colegio) {
        $actual->{derecha} = _insertar_rec($actual->{derecha}, $nuevo);
    } else {
        return $actual; # duplicado → no insertar
    }

    _actualizar_altura($actual);

    my $balance = _balance($actual);

    # Rotaciones
    if ($balance > 1 && $nuevo->obtener_numero_colegio lt $actual->{izquierda}->obtener_numero_colegio) {
        return _rotar_derecha($actual);
    }
    if ($balance < -1 && $nuevo->obtener_numero_colegio gt $actual->{derecha}->obtener_numero_colegio) {
        return _rotar_izquierda($actual);
    }
    if ($balance > 1 && $nuevo->obtener_numero_colegio gt $actual->{izquierda}->obtener_numero_colegio) {
        $actual->{izquierda} = _rotar_izquierda($actual->{izquierda});
        return _rotar_derecha($actual);
    }
    if ($balance < -1 && $nuevo->obtener_numero_colegio lt $actual->{derecha}->obtener_numero_colegio) {
        $actual->{derecha} = _rotar_derecha($actual->{derecha});
        return _rotar_izquierda($actual);
    }

    return $actual;
}

# ====================== BUSCAR ======================
sub buscar {
    my ($self, $numero_colegio) = @_;
    return _buscar_rec($self->{raiz}, $numero_colegio);
}

sub _buscar_rec {
    my ($actual, $clave) = @_;
    return undef unless defined $actual;

    if ($clave eq $actual->obtener_numero_colegio) {
        return $actual;
    } elsif ($clave lt $actual->obtener_numero_colegio) {
        return _buscar_rec($actual->{izquierda}, $clave);
    } else {
        return _buscar_rec($actual->{derecha}, $clave);
    }
}

# ====================== EXISTE ======================
sub existe {
    my ($self, $numero_colegio) = @_;
    my $nodo = $self->buscar($numero_colegio);
    return defined $nodo ? 1 : 0;
}

# ====================== ELIMINAR (con rebalanceo) ======================
sub eliminar {
    my ($self, $numero_colegio) = @_;
    $self->{raiz} = _eliminar_rec($self->{raiz}, $numero_colegio);
}

sub _eliminar_rec {
    my ($actual, $clave) = @_;
    return undef unless defined $actual;

    if ($clave lt $actual->obtener_numero_colegio) {
        $actual->{izquierda} = _eliminar_rec($actual->{izquierda}, $clave);
    } elsif ($clave gt $actual->obtener_numero_colegio) {
        $actual->{derecha} = _eliminar_rec($actual->{derecha}, $clave);
    } else {
        # Caso 1: sin hijos o un hijo
        return $actual->{izquierda} if !defined $actual->{derecha};
        return $actual->{derecha}   if !defined $actual->{izquierda};

        # Caso 2: dos hijos → sucesor in-order
        my $sucesor = _minimo_valor_nodo($actual->{derecha});
        # Copiar datos
        $actual->{numero_colegio}  = $sucesor->obtener_numero_colegio;
        $actual->{nombre_completo} = $sucesor->obtener_nombre;
        $actual->{tipo_usuario}    = $sucesor->obtener_tipo;
        $actual->{departamento}    = $sucesor->obtener_departamento;
        $actual->{especialidad}    = $sucesor->obtener_especialidad;
        $actual->{contrasena}      = $sucesor->obtener_contrasena;

        $actual->{derecha} = _eliminar_rec($actual->{derecha}, $sucesor->obtener_numero_colegio);
    }

    _actualizar_altura($actual);
    my $balance = _balance($actual);

    # Rebalanceo después de eliminar
    if ($balance > 1 && _balance($actual->{izquierda}) >= 0) {
        return _rotar_derecha($actual);
    }
    if ($balance > 1 && _balance($actual->{izquierda}) < 0) {
        $actual->{izquierda} = _rotar_izquierda($actual->{izquierda});
        return _rotar_derecha($actual);
    }
    if ($balance < -1 && _balance($actual->{derecha}) <= 0) {
        return _rotar_izquierda($actual);
    }
    if ($balance < -1 && _balance($actual->{derecha}) > 0) {
        $actual->{derecha} = _rotar_derecha($actual->{derecha});
        return _rotar_izquierda($actual);
    }

    return $actual;
}

sub _minimo_valor_nodo {
    my $nodo = shift;
    while (defined $nodo->{izquierda}) {
        $nodo = $nodo->{izquierda};
    }
    return $nodo;
}

# ====================== RECORRIDOS ======================
sub pre_orden  { my $self = shift; _pre_orden_rec($self->{raiz}); }
sub in_orden   { my $self = shift; _in_orden_rec($self->{raiz}); }
sub post_orden { my $self = shift; _post_orden_rec($self->{raiz}); }

sub _pre_orden_rec {
    my $n = shift;
    return unless defined $n;
    print_personal($n);
    _pre_orden_rec($n->{izquierda});
    _pre_orden_rec($n->{derecha});
}

sub _in_orden_rec {
    my $n = shift;
    return unless defined $n;
    _in_orden_rec($n->{izquierda});
    print_personal($n);
    _in_orden_rec($n->{derecha});
}

sub _post_orden_rec {
    my $n = shift;
    return unless defined $n;
    _post_orden_rec($n->{izquierda});
    _post_orden_rec($n->{derecha});
    print_personal($n);
}

sub print_personal {
    my $n = shift;
    printf "%-12s | %-25s | %-10s | %-10s | %s\n",
           $n->obtener_numero_colegio,
           $n->obtener_nombre,
           $n->obtener_tipo,
           $n->obtener_departamento,
           $n->obtener_especialidad;
}

# ====================== GRAPHVIZ MEJORADO ======================

sub generar_dot {
    my ($self, $filename) = @_;

    open my $fh, '>', $filename or die "No se pudo crear $filename: $!";

    print $fh "digraph AVL_Personal {\n";
    print $fh "    node [shape=circle, style=filled, fontsize=10];\n";
    print $fh "    rankdir=TB;\n\n";

    _generar_dot_rec_mejorado($self->{raiz}, $fh, 1);

    print $fh "}\n";
    close $fh;
}

sub _generar_dot_rec_mejorado {
    my ($nodo, $fh, $es_raiz) = @_;
    return unless defined $nodo;

    my $id = $nodo->obtener_numero_colegio;

    my $label = "Colegio: $id\\n" .
                "Nombre: " . $nodo->obtener_nombre . "\\n" .
                "Tipo: " . $nodo->obtener_tipo . "\\n" .
                "Depto: " . $nodo->obtener_departamento;

    my $color = "lightblue";

    # Nodo raíz
    if ($es_raiz) {
        $color = "gold";
    }
    # Nodo hoja
    elsif (!defined $nodo->{izquierda} && !defined $nodo->{derecha}) {
        $color = "lightgreen";
    }

    print $fh "    \"$id\" [label=\"$label\", fillcolor=$color];\n";

    # Izquierda
    if (defined $nodo->{izquierda}) {
        my $izq = $nodo->{izquierda}->obtener_numero_colegio;
        print $fh "    \"$id\" -> \"$izq\" [label=\"Izq\"];\n";
        _generar_dot_rec_mejorado($nodo->{izquierda}, $fh, 0);
    }

    # Derecha
    if (defined $nodo->{derecha}) {
        my $der = $nodo->{derecha}->obtener_numero_colegio;
        print $fh "    \"$id\" -> \"$der\" [label=\"Der\"];\n";
        _generar_dot_rec_mejorado($nodo->{derecha}, $fh, 0);
    }
}

1;