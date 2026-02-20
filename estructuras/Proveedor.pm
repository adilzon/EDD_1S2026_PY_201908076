package Proveedor;

use strict;
use warnings;

sub crear {
    my ($codigo, $nombre, $telefono) = @_;

    my $self = {
        codigo    => $codigo,
        nombre    => $nombre,
        telefono  => $telefono,
        siguiente => undef,
        entregas  => undef,  # luego será una lista
    };

    return $self;
}

1;
