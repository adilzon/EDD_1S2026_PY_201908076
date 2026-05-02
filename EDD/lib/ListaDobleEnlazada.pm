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
    while (defined $actual) {
        if ($medicamento->obtener_codigo lt $actual->obtener_codigo) {
            last;
        }
        $actual = $actual->{siguiente};
    }

    if ($actual == $self->{cabeza}) {
        $medicamento->{siguiente} = $self->{cabeza};
        $self->{cabeza}->{anterior} = $medicamento;
        $self->{cabeza} = $medicamento;
    }
    elsif (!defined $actual) {
        $self->{cola}->{siguiente} = $medicamento;
        $medicamento->{anterior}   = $self->{cola};
        $self->{cola} = $medicamento;
    }
    else {
        my $anterior = $actual->{anterior};
        $anterior->{siguiente} = $medicamento;
        $medicamento->{anterior} = $anterior;
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

1;