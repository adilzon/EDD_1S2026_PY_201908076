use strict;
use warnings;

use lib 'estructuras';
use Medicamento;
use ListaInventario;
use Proveedor;
use ListaProveedores;
use Entrega;

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
        $codigo, $nombre, $principio, $laboratorio,
        $cantidad, $vencimiento, $precio, $minimo
    );

    ListaInventario::insertar($medicamento);

    print "\n✅ Medicamento registrado correctamente\n";
}

# ==================================================
# PROGRAMA PRINCIPAL
# ==================================================

print "\n=================================\n";
print "   SISTEMA EDD MedTrack\n";
print "=================================\n";

# ---------------- INVENTARIO ----------------
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

registrar_medicamento_consola();
ListaInventario::mostrar();
ListaInventario::generar_graphviz();

# ---------------- PROVEEDORES ----------------
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

# ---------------- ENTREGAS ----------------
print "\n=================================\n";
print "   PRUEBA DE ENTREGAS\n";
print "=================================\n";

my $e1 = Entrega::crear(
    "2025-02-01",
    "FAC-001",
    "Paracetamol",
    100
);

my $e2 = Entrega::crear(
    "2025-02-10",
    "FAC-002",
    "Ibuprofeno",
    50
);

my $e3 = Entrega::crear(
    "2025-02-15",
    "FAC-003",
    "Amoxicilina",
    200
);

Proveedor::agregar_entrega($p1, $e1);
Proveedor::agregar_entrega($p1, $e2);
Proveedor::agregar_entrega($p2, $e3);

# ---------------- GRAPHVIZ FINAL ----------------
ListaProveedores::generar_graphviz();