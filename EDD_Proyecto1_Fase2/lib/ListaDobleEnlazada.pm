#!/usr/bin/perl
use strict;
use warnings;

package ListaDobleEnlazada;

sub new {
    my $class = shift;
    my $self = {
        cabeza => undef,
        cola   => undef,
        tamano => 0
    };
    bless $self, $class;
    return $self;
}

sub insertar_ordenado {
    my ($self, $medicamento) = @_;

    if (!defined $self->{cabeza}) {
        $self->{cabeza} = $medicamento;
        $self->{cola}   = $medicamento;
        $self->{tamano} = 1;
        return;
    }

    my $actual = $self->{cabeza};
    my $prev   = undef;

    while (defined $actual) {
        if ($medicamento->obtener_codigo lt $actual->obtener_codigo) {
            last;
        }
        $prev   = $actual;
        $actual = $actual->{siguiente};
    }

    if (!defined $prev) {
        # insertar al inicio
        $medicamento->{siguiente} = $self->{cabeza};
        $self->{cabeza}->{anterior} = $medicamento;
        $self->{cabeza} = $medicamento;
    }
    elsif (!defined $actual) {
        # insertar al final
        $self->{cola}->{siguiente} = $medicamento;
        $medicamento->{anterior}   = $self->{cola};
        $self->{cola} = $medicamento;
    }
    else {
        # insertar en medio
        $prev->{siguiente} = $medicamento;
        $medicamento->{anterior} = $prev;
        $medicamento->{siguiente} = $actual;
        $actual->{anterior} = $medicamento;
    }

    $self->{tamano}++;
}

sub mostrar_todos {
    my $self = shift;

    # ←←← ESTA LÍNEA ELIMINA LOS WARNINGS
    return if !defined $self->{cabeza};

    print "=== INVENTARIO (Lista Doblemente Enlazada) ===\n";
    print "Codigo | Nombre | Cantidad | Fecha Venc. | Estado\n";
    print "------------------------------------------------\n";

    my $actual = $self->{cabeza};
    while (defined $actual) {
        my $estado = ($actual->obtener_cantidad < $actual->obtener_nivel_minimo) 
                     ? "BAJO STOCK" 
                     : "NORMAL";

        printf "%-8s | %-20s | %-8s | %-12s | %s\n",
               $actual->obtener_codigo,
               $actual->obtener_nombre,
               $actual->obtener_cantidad,
               $actual->obtener_fecha_vencimiento,
               $estado;

        $actual = $actual->{siguiente};
    }

    print "Total de medicamentos: " . $self->{tamano} . "\n\n";
}

sub buscar {
    my ($self, $codigo) = @_;

    my $actual = $self->{cabeza};

    while (defined $actual) {
        if (uc($actual->obtener_codigo) eq uc($codigo)) {
            return $actual;
        }
        $actual = $actual->{siguiente};
    }

    return undef;
}

sub generar_dot {
    my ($self, $archivo) = @_;

    open(my $fh, '>', $archivo) or die "No se pudo crear $archivo";

    print $fh "digraph G {\n";
    print $fh "rankdir=LR;\n";  # Horizontal
    print $fh "node [shape=rectangle, style=filled];\n\n";

    my $actual = $self->{cabeza};

    if (!defined $actual) {
        print $fh "vacio [label=\"Lista vacia\"];\n";
        print $fh "}\n";
        close $fh;
        return;
    }

    my $index = 0;
    my $anterior = undef;

    while (defined $actual) {

        my $codigo = $actual->obtener_codigo();
        my $nombre = $actual->obtener_nombre();
        my $cantidad = $actual->obtener_cantidad();
        my $fecha = $actual->obtener_fecha_vencimiento();
        my $minimo = $actual->obtener_nivel_minimo();

        #COLORES SEGÚN REGLA
        my $color = "palegreen";  # normal

        if ($cantidad < $minimo) {
            $color = "red";  # bajo stock
        }
        elsif ($fecha lt "2027-01-01") {  # puedes ajustar criterio
            $color = "yellow";  # próximo a vencer
        }

        print $fh "n$index [label=\"";
        print $fh "Codigo: $codigo\\n";
        print $fh "Nombre: $nombre\\n";
        print $fh "Cantidad: $cantidad\\n";
        print $fh "Vence: $fecha";
        print $fh "\", fillcolor=$color];\n";

        # Conexión doble (↔)
        if (defined $anterior) {
            print $fh "n" . ($index - 1) . " -> n$index;\n";
            print $fh "n$index -> n" . ($index - 1) . ";\n";
        }

        $anterior = $actual;
        $actual = $actual->{siguiente};
        $index++;
    }

    # 🔹 MARCAR CABEZA
    print $fh "inicio [shape=plaintext, label=\"INICIO\"];\n";
    print $fh "inicio -> n0;\n";

    # 🔹 MARCAR FINAL
    print $fh "fin [shape=plaintext, label=\"FIN\"];\n";
    print $fh "fin -> n" . ($index - 1) . ";\n";

    print $fh "}\n";
    close $fh;

    print "Reporte DOT generado en $archivo\n";
}

1;