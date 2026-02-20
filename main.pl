use strict;
use warnings;

use lib 'estructuras';
use Medicamento;
use ListaInventario;
use Proveedor;
use ListaProveedores;
use Entrega;
use ListaEntregas;

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

# ---- Datos de prueba (Inventario) ----
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

# ---- Reporte Graphviz Inventario ----
ListaInventario::generar_graphviz();

# ==================================================
# PRUEBA DIA 3: LISTA CIRCULAR DE PROVEEDORES
# ==================================================

print "\n=================================\n";
print "   PRUEBA DE PROVEEDORES\n";
print "=================================\n";

my $p1 = Proveedor::crear("P001", "Proveedor Uno", "5555-1111");
my $p2 = Proveedor::crear("P002", "Proveedor Dos", "5555-2222");
my $p3 = Proveedor::crear("P003", "Proveedor Tres", "5555-3333");

ListaProveedores::insertar($p1);
ListaProveedores::insertar($p2);
ListaProveedores::insertar($p3);

ListaProveedores::mostrar();

# ==================================================
# PRUEBA DIA 4: ENTREGAS POR PROVEEDOR
# ==================================================

print "\n=================================\n";
print "   PRUEBA DE ENTREGAS\n";
print "=================================\n";

my $e1 = Entrega::crear("E001", "2025-02-01", 100);
my $e2 = Entrega::crear("E002", "2025-02-10", 50);
my $e3 = Entrega::crear("E003", "2025-02-15", 200);

# Agregar entregas al proveedor 1
ListaEntregas::insertar($p1, $e1);
ListaEntregas::insertar($p1, $e2);

# Agregar entrega al proveedor 2
ListaEntregas::insertar($p2, $e3);

# Mostrar proveedores con entregas
ListaProveedores::mostrar();

print "\nDETALLE DE ENTREGAS POR PROVEEDOR:\n";
ListaEntregas::mostrar($p1);
ListaEntregas::mostrar($p2);
ListaEntregas::mostrar($p3);

# ==================================================
# REPORTE GRAPHVIZ DE PROVEEDORES
# ==================================================

ListaProveedores::generar_graphviz();