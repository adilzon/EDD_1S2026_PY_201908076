#!/usr/bin/perl
use strict;
use warnings;

package Entrega;

sub new {
    my ($class, $fecha, $factura, $codigo_med, $cantidad) = @_;
    my $self = {
        fecha      => $fecha,
        factura    => $factura,
        codigo_med => $codigo_med,
        cantidad   => $cantidad,
        siguiente  => undef
    };
    bless $self, $class;
    return $self;
}

sub obtener_info {
    my $self = shift;
    return "Fecha: $self->{fecha} | Factura: $self->{factura} | Med: $self->{codigo_med} | Cant: $self->{cantidad}";
}

1;