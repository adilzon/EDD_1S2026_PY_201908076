#!/usr/bin/perl
use strict;
use warnings;

package Proveedor;

# =============================================
# CONSTRUCTOR
# =============================================
sub new {
    my ($class, $nit, $nombre, $telefono, $direccion) = @_;

    my $self = {
        nit       => $nit,
        nombre    => $nombre,
        telefono  => $telefono,
        direccion => $direccion,
        entregas  => [],          # array de hashes con cada entrega
        siguiente => undef,
        anterior  => undef
    };

    bless $self, $class;
    return $self;
}

# =============================================
# GETTERS
# =============================================
sub obtener_nit       { $_[0]->{nit}; }
sub obtener_nombre    { $_[0]->{nombre}; }
sub obtener_telefono  { $_[0]->{telefono}; }
sub obtener_direccion { $_[0]->{direccion}; }

# =============================================
# AGREGAR ENTREGA (usado en carga masiva JSON)
# =============================================
sub agregar_entrega {
    my ($self, $fecha, $numero_factura, $tipo, $codigo, $nombre, $fabricante, $precio, $cantidad) = @_;

    push @{$self->{entregas}}, {
        fecha          => $fecha,
        numero_factura => $numero_factura,
        tipo           => $tipo,
        codigo         => $codigo,
        nombre         => $nombre,
        fabricante     => $fabricante,
        precio         => $precio,
        cantidad       => $cantidad
    };
}

# =============================================
# MOSTRAR ENTREGAS (para reportes)
# =============================================
sub mostrar_entregas {
    my $self = shift;

    print "  Entregas de $self->{nombre} ($self->{nit}):\n";
    if (@{$self->{entregas}} == 0) {
        print "    (sin entregas registradas)\n";
        return;
    }

    foreach my $e (@{$self->{entregas}}) {
        print "    - $e->{fecha} | Factura: $e->{numero_factura} | $e->{tipo} $e->{codigo} | Cant: $e->{cantidad}\n";
    }
}

1;