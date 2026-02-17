package ListaInventario;

use strict;
use warnings;

my $head = undef;
my $tail = undef;

sub insertar {
    my ($nuevo) = @_;

    # Lista vacía
    if (!defined $head) {
        $head = $tail = $nuevo;
        return;
    }

    # Insertar al inicio
    if ($nuevo->{codigo} lt $head->{codigo}) {
        $nuevo->{siguiente} = $head;
        $head->{anterior} = $nuevo;
        $head = $nuevo;
        return;
    }

    my $actual = $head;

    while (defined $actual->{siguiente} &&
           $actual->{siguiente}->{codigo} lt $nuevo->{codigo}) {
        $actual = $actual->{siguiente};
    }

    # Insertar al final
    if (!defined $actual->{siguiente}) {
        $actual->{siguiente} = $nuevo;
        $nuevo->{anterior} = $actual;
        $tail = $nuevo;
    }
    # Insertar en medio
    else {
        $nuevo->{siguiente} = $actual->{siguiente};
        $nuevo->{anterior} = $actual;
        $actual->{siguiente}->{anterior} = $nuevo;
        $actual->{siguiente} = $nuevo;
    }
}

sub mostrar {
    my $actual = $head;

    print "\n--- INVENTARIO ---\n";
    while ($actual) {
        print "Codigo: $actual->{codigo} | ";
        print "Nombre: $actual->{nombre} | ";
        print "Cantidad: $actual->{cantidad}\n";
        $actual = $actual->{siguiente};
    }
}

1;
