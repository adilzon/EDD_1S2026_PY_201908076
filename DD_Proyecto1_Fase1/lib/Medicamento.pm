#!/usr/bin/perl
use strict;
use warnings;

package Medicamento;

sub new {
    my ($class, $codigo, $nombre, $principio_activo, $laboratorio, $precio, $cantidad, $fecha_vencimiento, $nivel_minimo) = @_;

    my $self = {
        codigo           => $codigo,
        nombre           => $nombre,
        principio_activo => $principio_activo,
        laboratorio      => $laboratorio,
        precio           => $precio,
        cantidad         => $cantidad,
        fecha_vencimiento => $fecha_vencimiento,
        nivel_minimo     => $nivel_minimo,
        siguiente        => undef,
        anterior         => undef
    };

    bless $self, $class;
    return $self;
}

sub obtener_codigo {
    my $self = shift;
    return $self->{codigo};
}

sub obtener_nombre {
    my $self = shift;
    return $self->{nombre};
}

sub obtener_cantidad {
    my $self = shift;
    return $self->{cantidad};
}

sub obtener_fecha_vencimiento {
    my $self = shift;
    return $self->{fecha_vencimiento};
}

sub obtener_nivel_minimo {
    my $self = shift;
    return $self->{nivel_minimo};
}

sub actualizar_cantidad {
    my ($self, $nueva_cantidad) = @_;
    $self->{cantidad} = $nueva_cantidad;
}

1;   # Siempre termina un archivo .pm con 1