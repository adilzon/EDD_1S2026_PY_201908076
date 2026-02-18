use strict;
use warnings;

use lib 'estructuras';
use Medicamento;
use ListaInventario;

# ==================================================
# FUNCION: Registrar medicamento desde consola
# ==================================================
sub registrar_medicamento_consola {

    print "\n=================================\n";
    print "   REGISTRAR MEDICAMENTO\n";
    print "=================================\n";

    print "Codigo: ";
    chomp(my $codigo = <STDIN>);

    print "Nombre: ";
    chomp(my $nombre = <STDIN>);

    print "Principio activo: ";
    chomp(my $principio = <STDIN>);

    print "Laboratorio: ";
    chomp(my $laboratorio = <STDIN>);

    print "Cantidad en stock: ";
    chomp(my $cantidad = <STDIN>);

    print "Fecha de vencimiento (YYYY-MM-DD): ";
    chomp(my $vencimiento = <STDIN>);

    print "Precio: ";
    chomp(my $precio = <STDIN>);

    print "Nivel minimo de reorden: ";
    chomp(my $minimo = <STDIN>);

    my $medicamento = Medicamento::crear(
        $codigo,
        $nombre,
        $principio,
        $laboratorio,
        $cantidad,
        $vencimiento,
        $precio,
        $minimo
    );

    ListaInventario::insertar($medicamento);

    print "\n Medicamento registrado correctamente\n";
}

# ==================================================
# PROGRAMA PRINCIPAL
# ==================================================

print "\n=================================\n";
print "   SISTEMA EDD MedTrack\n";
print "=================================\n";

# ---- Datos de prueba ----
my $m1 = Medicamento::crear(
    "MED002", "Ibuprofeno", "Ibuprofeno",
    "LabA", 20, "2026-05-01", 5.50, 10
);

my $m2 = Medicamento::crear(
    "MED001", "Paracetamol", "Acetaminofen",
    "LabB", 50, "2026-01-01", 3.00, 15
);

my $m3 = Medicamento::crear(
    "MED003", "Amoxicilina", "Amoxicilina",
    "LabC", 10, "2025-12-01", 8.75, 5
);

ListaInventario::insertar($m1);
ListaInventario::insertar($m2);
ListaInventario::insertar($m3);

# ---- Registro desde consola ----
registrar_medicamento_consola();

# ---- Mostrar inventario actualizado ----
ListaInventario::mostrar();

# ----------------------------------
# PASO 3: Generar reporte Graphviz
# ----------------------------------
ListaInventario::generar_graphviz();
