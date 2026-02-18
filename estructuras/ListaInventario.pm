package ListaInventario;

use strict;
use warnings;
use Time::Piece;

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

# -----------------------------
# MOSTRAR INVENTARIO (DIA 2)
# -----------------------------
sub mostrar {
    my $actual = $head;
    my $hoy = Time::Piece->strptime(localtime->ymd, "%Y-%m-%d");

    print "\n--- INVENTARIO COMPLETO ---\n";

    while ($actual) {
        print "Codigo: $actual->{codigo}\n";
        print "Nombre: $actual->{nombre}\n";
        print "Cantidad: $actual->{cantidad}\n";
        print "Vence: $actual->{vencimiento}\n";
        print "Minimo: $actual->{minimo}\n";

        # Alerta por bajo stock
        if ($actual->{cantidad} < $actual->{minimo}) {
            print "ALERTA: Bajo stock\n";
        }

        # Alerta por vencimiento proximo
        my $vence = Time::Piece->strptime($actual->{vencimiento}, "%Y-%m-%d");
        if (($vence - $hoy)->days < 30) {
            print "ALERTA: Proximo a vencer\n";
        }

        print "---------------------------\n";
        $actual = $actual->{siguiente};
    }
}

# -----------------------------
# GENERAR GRAPHVIZ (PASO 2)
# -----------------------------
sub generar_graphviz {
    my $archivo = "Reportes/inventario.dot";
    open(my $fh, '>', $archivo) or die "No se pudo crear $archivo";

    print $fh "digraph Inventario {\n";
    print $fh "rankdir=LR;\n";
    print $fh "node [shape=record, style=filled];\n";

    my $actual = $head;
    my $i = 0;
    my $hoy = Time::Piece->strptime(localtime->ymd, "%Y-%m-%d");

    while ($actual) {
        my $color = "lightgreen";  # 🟢 Normal

        # ---- calcular vencimiento ----
        my $vence = Time::Piece->strptime($actual->{vencimiento}, "%Y-%m-%d");
        my $dias = ($vence - $hoy)->days;

        # ---- reglas de colores ----
        if ($actual->{cantidad} < $actual->{minimo}) {
            $color = "lightcoral";   # 🔴 Bajo stock
        }
        elsif ($dias < 30) {
            $color = "khaki";        # 🟡 Próximo a vencer
        }

        print $fh "n$i [label=\"{";
        print $fh "Codigo: $actual->{codigo}\\l";
        print $fh "Nombre: $actual->{nombre}\\l";
        print $fh "Cantidad: $actual->{cantidad}\\l";
        print $fh "Vence: $actual->{vencimiento}\\l";
        print $fh "}\", fillcolor=\"$color\"];\n";

        if ($actual->{siguiente}) {
            print $fh "n$i -> n" . ($i + 1) . ";\n";
            print $fh "n" . ($i + 1) . " -> n$i;\n";
        }

        $actual = $actual->{siguiente};
        $i++;
    }

    print $fh "}\n";
    close($fh);

    system("dot -Tpng Reportes/inventario.dot -o Reportes/inventario.png");
}



1;
