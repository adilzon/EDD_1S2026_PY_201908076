#!/usr/bin/perl
use strict;
use warnings;

package NodoSuministro;

sub new {
    my ($class, $codigo, $nombre, $fabricante, $precio_unitario, $cantidad, $fecha_vencimiento, $nivel_minimo) = @_;

    my $self = {
        codigo           => $codigo,
        nombre           => $nombre,
        fabricante       => $fabricante,
        precio_unitario  => $precio_unitario,
        cantidad         => $cantidad,
        fecha_vencimiento => $fecha_vencimiento,
        nivel_minimo     => $nivel_minimo
    };

    bless $self, $class;
    return $self;
}

# Getters
sub obtener_codigo          { $_[0]->{codigo}; }
sub obtener_nombre          { $_[0]->{nombre}; }
sub obtener_fabricante      { $_[0]->{fabricante}; }
sub obtener_precio          { $_[0]->{precio_unitario}; }
sub obtener_cantidad        { $_[0]->{cantidad}; }
sub obtener_fecha_vencimiento { $_[0]->{fecha_vencimiento}; }
sub obtener_nivel_minimo    { $_[0]->{nivel_minimo}; }

sub actualizar_cantidad {
    my ($self, $nueva) = @_;
    $self->{cantidad} = $nueva;
}

1;