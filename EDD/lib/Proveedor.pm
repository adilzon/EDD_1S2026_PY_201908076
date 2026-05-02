#!/usr/bin/perl
use strict;
use warnings;

package Proveedor;

sub new {
    my ($class, $nit, $nombre, $contacto, $telefono, $direccion) = @_;
    my $self = {
        nit       => $nit,
        nombre    => $nombre,
        contacto  => $contacto,
        telefono  => $telefono,
        direccion => $direccion,
        entregas  => [],          # lista simple de entregas (array)
        siguiente => undef,
        anterior  => undef
    };
    bless $self, $class;
    return $self;
}

sub obtener_nit    { my $self = shift; return $self->{nit}; }
sub obtener_nombre { my $self = shift; return $self->{nombre}; }
sub agregar_entrega {
    my ($self, $fecha, $factura, $codigo_medicamento, $cantidad) = @_;
    push @{$self->{entregas}}, {
        fecha              => $fecha,
        factura            => $factura,
        codigo_medicamento => $codigo_medicamento,
        cantidad           => $cantidad
    };
}

sub mostrar_entregas {
    my $self = shift;
    print "  Entregas de $self->{nombre} ($self->{nit}):\n";
    if (@{$self->{entregas}} == 0) {
        print "    (sin entregas registradas)\n";
    } else {
        foreach my $e (@{$self->{entregas}}) {
            print "    - $e->{fecha} | Factura: $e->{factura} | Med: $e->{codigo_medicamento} | Cant: $e->{cantidad}\n";
        }
    }
}

1;