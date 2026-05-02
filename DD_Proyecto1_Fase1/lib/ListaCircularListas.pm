#!/usr/bin/perl
use strict;
use warnings;

package ListaCircularListas;

sub new {
    my $class = shift;
    my $self = {
        cabeza => undef,
        tamano => 0
    };
    bless $self, $class;
    return $self;
}

sub insertar_proveedor {
    my ($self, $proveedor) = @_;

    if (!defined $self->{cabeza}) {
        $self->{cabeza} = $proveedor;
        $proveedor->{siguiente} = $proveedor;
        $proveedor->{anterior}  = $proveedor;   # ← ESTA LÍNEA FALTABA
        $self->{tamano} = 1;
        return;
    }

    # Insertar al final de la lista circular
    my $ultimo = $self->{cabeza}->{anterior};
    $ultimo->{siguiente} = $proveedor;
    $proveedor->{anterior} = $ultimo;
    $proveedor->{siguiente} = $self->{cabeza};
    $self->{cabeza}->{anterior} = $proveedor;

    $self->{tamano}++;
}

sub buscar_proveedor {
    my ($self, $nit) = @_;
    return undef unless defined $self->{cabeza};
    my $actual = $self->{cabeza};
    do {
        return $actual if ($actual->obtener_nit eq $nit);
        $actual = $actual->{siguiente};
    } while ($actual != $self->{cabeza});
    return undef;
}

sub mostrar_todos {
    my $self = shift;
    return if !defined $self->{cabeza};

    print "=== PROVEEDORES ===\n";
    my $actual = $self->{cabeza};
    do {
        print "NIT: " . $actual->obtener_nit . " | Nombre: " . $actual->obtener_nombre . "\n";
        $actual->mostrar_entregas();
        print "----------------\n";
        $actual = $actual->{siguiente};
    } while ($actual != $self->{cabeza});
    print "Total proveedores: " . $self->{tamano} . "\n\n";
}

1;