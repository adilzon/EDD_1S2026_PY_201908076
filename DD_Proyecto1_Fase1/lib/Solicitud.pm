#!/usr/bin/perl
use strict;
use warnings;

package Solicitud;

sub new {
    my ($class, $numero, $departamento, $codigo_medicamento, $cantidad, $prioridad, $justificacion) = @_;
    my $self = {
        numero             => $numero,
        departamento       => $departamento,
        codigo_medicamento => $codigo_medicamento,
        cantidad           => $cantidad,
        prioridad          => $prioridad,
        justificacion      => $justificacion,
        estado             => "pendiente",
        siguiente          => undef,
        anterior           => undef
    };
    bless $self, $class;
    return $self;
}

# =========================
# GETTERS
# =========================

sub obtener_numero {
    my $self = shift;
    return $self->{numero};
}

sub obtener_departamento {
    my $self = shift;
    return $self->{departamento};
}

sub obtener_codigo_medicamento {
    my $self = shift;
    return $self->{codigo_medicamento};
}

sub obtener_cantidad {
    my $self = shift;
    return $self->{cantidad};
}

sub obtener_prioridad {
    my $self = shift;
    return $self->{prioridad};
}

sub obtener_estado {
    my $self = shift;
    return $self->{estado};
}

# =========================
# SETTERS
# =========================

sub cambiar_estado {
    my ($self, $nuevo_estado) = @_;
    $self->{estado} = $nuevo_estado;
}

1;