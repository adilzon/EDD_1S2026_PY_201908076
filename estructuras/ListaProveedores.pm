package ListaProveedores;

use strict;
use warnings;

my $head = undef;

sub insertar {
    my ($nuevo) = @_;

    # Lista vacía
    if (!defined $head) {
        $head = $nuevo;
        $nuevo->{siguiente} = $head;
        return;
    }

    # Insertar al final (antes del head)
    my $actual = $head;
    while ($actual->{siguiente} != $head) {
        $actual = $actual->{siguiente};
    }

    $actual->{siguiente} = $nuevo;
    $nuevo->{siguiente} = $head;
}

sub mostrar {
    return unless defined $head;

    print "\n--- LISTA DE PROVEEDORES ---\n";

    my $actual = $head;
    do {
        print "Codigo: $actual->{codigo} | ";
        print "Nombre: $actual->{nombre} | ";
        print "Telefono: $actual->{telefono}\n";

        $actual = $actual->{siguiente};
    } while ($actual != $head);
}

# ==================================================
# FUNCION: Generar reporte Graphviz de proveedores
# ==================================================
sub generar_graphviz {
    my $archivo = "Reportes/proveedores.dot";
    open(my $fh, '>', $archivo) or die "No se pudo crear $archivo";

    print $fh "digraph Proveedores {\n";
    print $fh "rankdir=LR;\n";
    print $fh "node [shape=box, style=filled, fillcolor=lightblue];\n";

    return unless defined $head;

    my $actual = $head;
    my %ids;
    my $i = 0;

    # ---- Crear nodos de proveedores ----
    do {
        $ids{$actual} = "p$i";
        print $fh "p$i [label=\"";
        print $fh "Codigo: $actual->{codigo}\\n";
        print $fh "Nombre: $actual->{nombre}\\n";
        print $fh "Telefono: $actual->{telefono}";
        print $fh "\"];\n";

        $actual = $actual->{siguiente};
        $i++;
    } while ($actual != $head);

    # ---- Conectar proveedores (lista circular) ----
    $actual = $head;
    do {
        my $sig = $actual->{siguiente};
        print $fh "$ids{$actual} -> $ids{$sig};\n";
        $actual = $sig;
    } while ($actual != $head);

    # ---- Entregas por proveedor ----
    print $fh "node [shape=ellipse, fillcolor=lightyellow];\n";

    $actual = $head;
    my $e = 0;

    do {
        my $ent = $actual->{entregas};
        my $prev;

        while ($ent) {
            my $eid = "e$e";
            print $fh "$eid [label=\"";
            print $fh "Entrega: $ent->{codigo}\\n";
            print $fh "Fecha: $ent->{fecha}\\n";
            print $fh "Cantidad: $ent->{cantidad}";
            print $fh "\"];\n";

            if (!$prev) {
                print $fh "$ids{$actual} -> $eid;\n";
            } else {
                print $fh "$prev -> $eid;\n";
            }

            $prev = $eid;
            $ent = $ent->{siguiente};
            $e++;
        }

        $actual = $actual->{siguiente};
    } while ($actual != $head);

    print $fh "}\n";
    close($fh);

    system("dot -Tpng Reportes/proveedores.dot -o Reportes/proveedores.png");
}

1;