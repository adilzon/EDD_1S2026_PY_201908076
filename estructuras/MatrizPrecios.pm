package MatrizPrecios;

use strict;
use warnings;

use matriz_dispersa::MatrizDispersa;

my $matriz = matriz_dispersa::MatrizDispersa->new();

my %map_med;   # nombre medicamento -> indice fila
my %map_prov;  # codigo proveedor -> indice columna
my $fila = 0;
my $col  = 0;

sub registrar_precio {
    my ($proveedor, $medicamento, $precio) = @_;

    if (!exists $map_med{$medicamento}) {
        $map_med{$medicamento} = $fila++;
    }

    if (!exists $map_prov{$proveedor}) {
        $map_prov{$proveedor} = $col++;
    }

    my $f = $map_med{$medicamento};
    my $c = $map_prov{$proveedor};

    $matriz->insertar($f, $c, $precio);
}

sub mostrar {
    $matriz->imprimir_matriz();
}

sub mostrar_lista {
    $matriz->imprimir_lista();
}

1;