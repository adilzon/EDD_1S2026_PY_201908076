#!/usr/bin/perl
use strict;
use warnings;

package MatrizDispersaProveedorFabricante;

use NodoCabecera;
use NodoDato;         

# =============================================
# CONSTRUCTOR
# =============================================
sub new {
    my $class = shift;
    my $self = {
        lista_filas => undef,   # Cabeceras de PROVEEDORES
        lista_cols  => undef,   # Cabeceras de FABRICANTES
        num_filas   => 0,
        num_cols    => 0,
        total_datos => 0,
    };
    bless $self, $class;
    return $self;
}

# =============================================
# BUSQUEDA DE CABECERAS
# =============================================
sub _buscar_cab_fila {
    my ($self, $fila_idx) = @_;
    my $actual = $self->{lista_filas};
    while (defined $actual) {
        return $actual if ($actual->get_label() == $fila_idx);
        last if ($actual->get_label() > $fila_idx);
        $actual = $actual->get_next();
    }
    return undef;
}

sub _buscar_cab_col {
    my ($self, $col_idx) = @_;
    my $actual = $self->{lista_cols};
    while (defined $actual) {
        return $actual if ($actual->get_label() == $col_idx);
        last if ($actual->get_label() > $col_idx);
        $actual = $actual->get_next();
    }
    return undef;
}

# =============================================
# CREAR CABECERAS
# =============================================
sub _obtener_o_crear_cab_fila {
    my ($self, $fila_idx) = @_;
    # ... (código idéntico al tuyo)
    if (!defined $self->{lista_filas}) {
        my $nueva = NodoCabecera->new($fila_idx);
        $self->{lista_filas} = $nueva;
        return $nueva;
    }
    if ($self->{lista_filas}->get_label() > $fila_idx) {
        my $nueva = NodoCabecera->new($fila_idx);
        $nueva->set_next($self->{lista_filas});
        $self->{lista_filas} = $nueva;
        return $nueva;
    }
    if ($self->{lista_filas}->get_label() == $fila_idx) {
        return $self->{lista_filas};
    }

    my $anterior = $self->{lista_filas};
    my $actual   = $anterior->get_next();

    while (defined $actual) {
        if ($actual->get_label() == $fila_idx) {
            return $actual;
        }
        if ($actual->get_label() > $fila_idx) {
            my $nueva = NodoCabecera->new($fila_idx);
            $nueva->set_next($actual);
            $anterior->set_next($nueva);
            return $nueva;
        }
        $anterior = $actual;
        $actual   = $actual->get_next();
    }

    my $nueva = NodoCabecera->new($fila_idx);
    $anterior->set_next($nueva);
    return $nueva;
}

sub _obtener_o_crear_cab_col {
    my ($self, $col_idx) = @_;
    # ... (código idéntico al tuyo, solo cambiado el nombre)
    if (!defined $self->{lista_cols}) {
        my $nueva = NodoCabecera->new($col_idx);
        $self->{lista_cols} = $nueva;
        return $nueva;
    }
    if ($self->{lista_cols}->get_label() > $col_idx) {
        my $nueva = NodoCabecera->new($col_idx);
        $nueva->set_next($self->{lista_cols});
        $self->{lista_cols} = $nueva;
        return $nueva;
    }
    if ($self->{lista_cols}->get_label() == $col_idx) {
        return $self->{lista_cols};
    }

    my $anterior = $self->{lista_cols};
    my $actual   = $anterior->get_next();

    while (defined $actual) {
        if ($actual->get_label() == $col_idx) {
            return $actual;
        }
        if ($actual->get_label() > $col_idx) {
            my $nueva = NodoCabecera->new($col_idx);
            $nueva->set_next($actual);
            $anterior->set_next($nueva);
            return $nueva;
        }
        $anterior = $actual;
        $actual   = $actual->get_next();
    }

    my $nueva = NodoCabecera->new($col_idx);
    $anterior->set_next($nueva);
    return $nueva;
}

# =============================================
# INSERTAR (Proveedor vs Fabricante)
# =============================================
sub insertar {
    my ($self, $proveedor_nit, $fabricante, $cantidad) = @_;

    # Mapear strings a índices dinámicos
    my $fila_idx = _obtener_indice_fila($self, $proveedor_nit);
    my $col_idx  = _obtener_indice_col($self, $fabricante);

    my $cab_fila = $self->_obtener_o_crear_cab_fila($fila_idx);
    my $cab_col  = $self->_obtener_o_crear_cab_col($col_idx);

    # Verificar si ya existe
    my $existente = $self->obtener($fila_idx, $col_idx);
    if (defined $existente) {
        my $valor_actual = $existente->get_valor();
        $existente->set_valor($valor_actual + $cantidad);   # acumular cantidad
        return;
    }

    my $nuevo = NodoDato->new($fila_idx, $col_idx, $cantidad);

    # Insertar en fila (horizontal)
    if (!defined $cab_fila->get_right()) {
        $cab_fila->set_right($nuevo);
    } elsif ($cab_fila->get_right()->get_col() > $col_idx) {
        my $primero = $cab_fila->get_right();
        $nuevo->set_right($primero);
        $primero->set_left($nuevo);
        $cab_fila->set_right($nuevo);
    } else {
        my $anterior = $cab_fila->get_right();
        my $actual   = $anterior->get_right();
        while (defined $actual && $actual->get_col() < $col_idx) {
            $anterior = $actual;
            $actual   = $actual->get_right();
        }
        $nuevo->set_right($actual);
        $nuevo->set_left($anterior);
        $anterior->set_right($nuevo);
        $actual->set_left($nuevo) if defined $actual;
    }

    # Insertar en columna (vertical)
    if (!defined $cab_col->get_down()) {
        $cab_col->set_down($nuevo);
    } elsif ($cab_col->get_down()->get_fila() > $fila_idx) {
        my $primero = $cab_col->get_down();
        $nuevo->set_down($primero);
        $primero->set_up($nuevo);
        $cab_col->set_down($nuevo);
    } else {
        my $anterior = $cab_col->get_down();
        my $actual   = $anterior->get_down();
        while (defined $actual && $actual->get_fila() < $fila_idx) {
            $anterior = $actual;
            $actual   = $actual->get_down();
        }
        $nuevo->set_down($actual);
        $nuevo->set_up($anterior);
        $anterior->set_down($nuevo);
        $actual->set_up($nuevo) if defined $actual;
    }

    $self->{total_datos}++;
}

# Helpers para mapear strings a índices
my %map_proveedores;
my %map_fabricantes;
my $fila_counter = 0;
my $col_counter  = 0;

sub _obtener_indice_fila {
    my ($self, $nit) = @_;
    unless (exists $map_proveedores{$nit}) {
        $map_proveedores{$nit} = $fila_counter++;
    }
    return $map_proveedores{$nit};
}

sub _obtener_indice_col {
    my ($self, $fabricante) = @_;
    unless (exists $map_fabricantes{$fabricante}) {
        $map_fabricantes{$fabricante} = $col_counter++;
    }
    return $map_fabricantes{$fabricante};
}

# =============================================
# OBTENER
# =============================================
sub obtener {
    my ($self, $fila, $col) = @_;
    my $cab_fila = $self->_buscar_cab_fila($fila);
    return undef unless defined $cab_fila;

    my $actual = $cab_fila->get_right();
    while (defined $actual) {
        return $actual if ($actual->get_col() == $col);
        last if ($actual->get_col() > $col);
        $actual = $actual->get_right();
    }
    return undef;
}

# =============================================
# IMPRESIÓN
# =============================================
sub mostrar {
    my $self = shift;
    print "\n=== MATRIZ DISPERSA (Proveedores vs Fabricantes) ===\n";
    print "Total relaciones activas: $self->{total_datos}\n\n";

    if (!defined $self->{lista_filas}) {
        print "(matriz vacía)\n";
        return;
    }

    my $cab_fila = $self->{lista_filas};
    while (defined $cab_fila) {
        print "Proveedor (fila $cab_fila->{label}):\n";
        my $nodo = $cab_fila->get_right();
        while (defined $nodo) {
            print "   → Fabricante (col $nodo->{col}): Cantidad total = " . $nodo->get_valor() . "\n";
            $nodo = $nodo->get_right();
        }
        $cab_fila = $cab_fila->get_next();
    }
    print "==================================================\n\n";
}

sub obtener_todo {
    my $self = shift;
    my @datos;

    # mapas inversos (para recuperar nombres reales)
    my %inv_prov = reverse %map_proveedores;
    my %inv_fab  = reverse %map_fabricantes;

    my $cab_fila = $self->{lista_filas};

    while (defined $cab_fila) {
        my $fila_idx = $cab_fila->get_label();
        my $proveedor = $inv_prov{$fila_idx} // "Desconocido";

        my $nodo = $cab_fila->get_right();

        while (defined $nodo) {
            my $col_idx = $nodo->get_col();
            my $fabricante = $inv_fab{$col_idx} // "Desconocido";

            push @datos, [
                $proveedor,
                $fabricante,
                $nodo->get_valor()
            ];

            $nodo = $nodo->get_right();
        }

        $cab_fila = $cab_fila->get_next();
    }

    return @datos;
}

# =============================================
# REPORTE GRAPHVIZ
# =============================================
sub generar_graphviz {
    my ($self, $archivo) = @_;

    open(my $fh, '>', $archivo) or die "No se pudo crear $archivo: $!";

    print $fh "digraph Matriz {\n";
    print $fh "    rankdir=TB;\n";
    print $fh "    node [fontname=\"Arial\"];\n\n";

    # Mapas inversos
    my %inv_prov = reverse %map_proveedores;
    my %inv_fab  = reverse %map_fabricantes;

    # =============================
    # NODOS CABECERA
    # =============================
    print $fh "    // Proveedores (Filas)\n";
    foreach my $idx (values %map_proveedores) {
        my $prov = $inv_prov{$idx};
        my $id = "P$idx";
        print $fh "    $id [label=\"$prov\", shape=box, style=filled, color=lightblue];\n";
    }

    print $fh "\n    // Fabricantes (Columnas)\n";
    foreach my $idx (values %map_fabricantes) {
        my $fab = $inv_fab{$idx};
        my $id = "F$idx";
        print $fh "    $id [label=\"$fab\", shape=box, style=filled, color=lightgreen];\n";
    }

    # =============================
    # NODOS DE VALOR
    # =============================
    print $fh "\n    // Valores\n";

    my $cab_fila = $self->{lista_filas};

    while (defined $cab_fila) {
        my $fila_idx = $cab_fila->get_label();
        my $nodo = $cab_fila->get_right();

        while (defined $nodo) {
            my $col_idx = $nodo->get_col();
            my $valor   = $nodo->get_valor();

            my $id_val = "N_${fila_idx}_${col_idx}";

            # Nodo valor (círculo)
            print $fh "    $id_val [label=\"$valor\", shape=circle, style=filled, color=orange];\n";

            # Conexión horizontal (Proveedor → valor)
            print $fh "    P$fila_idx -> $id_val;\n";

            # Conexión vertical (Fabricante → valor)
            print $fh "    F$col_idx -> $id_val;\n";

            $nodo = $nodo->get_right();
        }

        $cab_fila = $cab_fila->get_next();
    }

    # =============================
    # ALINEACIÓN (MATRIZ VISUAL)
    # =============================
    print $fh "\n    { rank=same; ";

    foreach my $idx (values %map_fabricantes) {
        print $fh "F$idx; ";
    }

    print $fh "}\n";

    print $fh "}\n";

    close($fh);

    print "✅ Reporte Graphviz tipo matriz generado: $archivo\n";
}

1;