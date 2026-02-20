package ListaProveedores;

use strict;
use warnings;

my $head = undef;

# =========================================
# Insertar proveedor en lista circular
# =========================================
sub insertar {
    my ($nuevo) = @_;

    if (!defined $head) {
        $head = $nuevo;
        $nuevo->{siguiente} = $nuevo;
        $nuevo->{anterior}  = $nuevo;
        return;
    }

    my $tail = $head->{anterior};

    $tail->{siguiente} = $nuevo;
    $nuevo->{anterior} = $tail;
    $nuevo->{siguiente} = $head;
    $head->{anterior}  = $nuevo;
}

# =========================================
# Mostrar proveedores en consola
# =========================================
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

# =========================================
# Graphviz: Lista circular de listas
# =========================================
sub generar_graphviz {
    my $archivo = "Reportes/proveedores_entregas.dot";
    open(my $fh, '>', $archivo) or die "No se pudo crear $archivo";

    print $fh "digraph ProveedoresEntregas {\n";
    print $fh "rankdir=LR;\n";
    print $fh "splines=ortho;\n";
    print $fh "node [style=filled];\n";

    return unless defined $head;

    my %pid;
    my $actual = $head;
    my $i = 0;

    # =====================================
    # PROVEEDORES (HORIZONTAL)
    # =====================================
    print $fh "{ rank=same;\n";
    do {
        $pid{$actual} = "p$i";

        print $fh "p$i [shape=box, fillcolor=lightblue, label=\"";
        print $fh "NIT: $actual->{codigo}\\n";
        print $fh "Nombre: $actual->{nombre}\"];\n";

        $actual = $actual->{siguiente};
        $i++;
    } while ($actual != $head);
    print $fh "}\n";

    # Enlaces circulares
    $actual = $head;
    do {
        print $fh "$pid{$actual} -> $pid{$actual->{siguiente}};\n";
        $actual = $actual->{siguiente};
    } while ($actual != $head);

    # =====================================
    # ENTREGAS (UNA COLUMNA POR PROVEEDOR)
    # =====================================
    my $e = 0;
    $actual = $head;

    do {
        my $ent = $actual->{entregas};
        my $prev;

        # Subgraph por proveedor (FUERZA vertical)
        print $fh "subgraph cluster_$pid{$actual} {\n";
        print $fh "rank=source;\n";

        while ($ent) {
            my $eid = "e$e";

            print $fh "$eid [shape=box, fillcolor=lightyellow, label=\"";
            print $fh "Fecha: $ent->{fecha}\\n";
            print $fh "Factura: $ent->{factura}\\n";
            print $fh "Medicamento: $ent->{medicamento}\\n";
            print $fh "Cantidad: $ent->{cantidad}\"];\n";

            if (!$prev) {
                print $fh "$pid{$actual} -> $eid;\n";
            } else {
                print $fh "$prev -> $eid;\n";
            }

            $prev = $eid;
            $ent  = $ent->{siguiente};
            $e++;
        }

        print $fh "}\n";

        $actual = $actual->{siguiente};
    } while ($actual != $head);

    print $fh "}\n";
    close($fh);

    system("dot -Tpng Reportes/proveedores_entregas.dot -o Reportes/proveedores_entregas.png");
    print "Diagrama generado en: Reportes/proveedores_entregas.png\n";
}

1;