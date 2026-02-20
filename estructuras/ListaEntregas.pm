package ListaEntregas;

use strict;
use warnings;

sub insertar {
    my ($proveedor, $nueva) = @_;

    # Si el proveedor no tiene entregas aún
    if (!defined $proveedor->{entregas}) {
        $proveedor->{entregas} = $nueva;
        return;
    }

    my $actual = $proveedor->{entregas};
    while ($actual->{siguiente}) {
        $actual = $actual->{siguiente};
    }

    $actual->{siguiente} = $nueva;
}

sub mostrar {
    my ($proveedor) = @_;

    print "  Entregas:\n";

    my $actual = $proveedor->{entregas};
    if (!defined $actual) {
        print "   - No hay entregas registradas\n";
        return;
    }

    while ($actual) {
        print "   Codigo: $actual->{codigo} | ";
        print "Fecha: $actual->{fecha} | ";
        print "Cantidad: $actual->{cantidad}\n";

        $actual = $actual->{siguiente};
    }
}

1;
