#!/usr/bin/perl
use strict;
use warnings;

package ListaCircularProveedores;

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
        $proveedor->{anterior}  = $proveedor;
        $self->{tamano} = 1;
        return;
    }
    my $ultimo = $self->{cabeza}->{anterior};
    $ultimo->{siguiente} = $proveedor;
    $proveedor->{anterior} = $ultimo;
    $proveedor->{siguiente} = $self->{cabeza};
    $self->{cabeza}->{anterior} = $proveedor;
    $self->{tamano}++;
}

sub buscar_por_nit {
    my ($self, $nit) = @_;
    return undef if !defined $self->{cabeza};
    my $actual = $self->{cabeza};
    do {
        if ($actual->obtener_nit eq $nit) {
            return $actual;
        }
        $actual = $actual->{siguiente};
    } while ($actual != $self->{cabeza});
    return undef;
}

1;