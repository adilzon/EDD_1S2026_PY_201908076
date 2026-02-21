package ListaInventario;

use strict;
use warnings;
use Time::Piece;
use Medicamento;

my $head = undef;
my $tail = undef;

# =========================================
# Contador de índices automáticos (MATRIZ)
# =========================================
my $indice_auto = 0;

# =========================================
# Insertar medicamento en lista doble ordenada
# =========================================
sub insertar {
    my ($nuevo) = @_;

    # ASIGNAR ÍNDICE AUTOMÁTICO (IMPORTANTE)
    $nuevo->{indice} = $indice_auto;
    $indice_auto++;

    # Lista vacía
    if (!defined $head) {
        $head = $tail = $nuevo;
        return;
    }

    # Insertar al inicio
    if ($nuevo->{codigo} lt $head->{codigo}) {
        $nuevo->{siguiente} = $head;
        $head->{anterior}   = $nuevo;
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
        $nuevo->{anterior}   = $actual;
        $tail = $nuevo;
    }
    # Insertar en medio
    else {
        $nuevo->{siguiente} = $actual->{siguiente};
        $nuevo->{anterior}  = $actual;
        $actual->{siguiente}->{anterior} = $nuevo;
        $actual->{siguiente} = $nuevo;
    }
}

# =========================================
# Mostrar inventario con alertas (DÍA 2)
# =========================================
sub mostrar {
    my $actual = $head;
    my $hoy = Time::Piece->strptime(localtime->ymd, "%Y-%m-%d");

    print "\n--- INVENTARIO COMPLETO ---\n";

    while ($actual) {
        print "Indice: $actual->{indice}\n";
        print "Codigo: $actual->{codigo}\n";
        print "Nombre: $actual->{nombre}\n";
        print "Cantidad: $actual->{cantidad}\n";
        print "Vence: $actual->{vencimiento}\n";
        print "Minimo: $actual->{minimo}\n";

        # Bajo stock
        if ($actual->{cantidad} < $actual->{minimo}) {
            print "ALERTA: Bajo stock\n";
        }

        # Próximo a vencer
        my $vence = Time::Piece->strptime($actual->{vencimiento}, "%Y-%m-%d");
        if (($vence - $hoy)->days < 30) {
            print "ALERTA: Proximo a vencer\n";
        }

        print "---------------------------\n";
        $actual = $actual->{siguiente};
    }
}

# =========================================
# Generar reporte Graphviz (DÍA 2)
# =========================================
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
        my $color = "lightgreen";

        my $vence = Time::Piece->strptime($actual->{vencimiento}, "%Y-%m-%d");
        my $dias = ($vence - $hoy)->days;

        if ($actual->{cantidad} < $actual->{minimo}) {
            $color = "lightcoral";
        }
        elsif ($dias < 30) {
            $color = "khaki";
        }

        print $fh "n$i [label=\"{";
        print $fh "Indice: $actual->{indice}\\l";
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

# =========================================
# Buscar medicamento por nombre (DÍA 4)
# =========================================
sub buscar_por_nombre {
    my ($nombre) = @_;
    my $actual = $head;

    while ($actual) {
        return $actual if lc($actual->{nombre}) eq lc($nombre);
        $actual = $actual->{siguiente};
    }

    return undef;
}

# =========================================
# Obtener indice de medicamento por nombre
# (NECESARIO PARA MATRIZ DISPERSA)
# =========================================
sub obtener_indice_por_nombre {
    my ($nombre) = @_;
    my $actual = $head;

    while ($actual) {
        if (lc($actual->{nombre}) eq lc($nombre)) {
            return $actual->{indice};
        }
        $actual = $actual->{siguiente};
    }

    return undef;
}

# =========================================
# CARGA MASIVA DESDE ARCHIVO CSV (DÍA 5)
# =========================================
sub carga_masiva {
    my ($ruta) = @_;

    open(my $fh, '<', $ruta) or die "No se pudo abrir el archivo $ruta\n";

    my $encabezado = <$fh>;
    my $contador = 0;

    while (my $linea = <$fh>) {
        chomp $linea;
        next if $linea =~ /^\s*$/;

        my (
            $codigo,
            $nombre,
            $principio,
            $laboratorio,
            $precio,
            $cantidad,
            $vencimiento,
            $minimo
        ) = split /,/, $linea;

        next unless
            defined $codigo &&
            defined $vencimiento &&
            $vencimiento =~ /^\d{4}-\d{2}-\d{2}$/ &&
            $cantidad =~ /^\d+(\.\d+)?$/ &&
            $minimo =~ /^\d+$/;

        my $med = Medicamento::crear(
            $codigo,
            $nombre,
            $principio,
            $laboratorio,
            $cantidad,
            $vencimiento,
            $precio,
            $minimo
        );

        insertar($med);
        $contador++;
    }

    close($fh);
    print "\n Carga masiva completada: $contador medicamentos cargados\n";
}

1;