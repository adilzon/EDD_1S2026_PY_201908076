use strict;
use warnings;

use lib 'estructuras';

use Medicamento;
use ListaInventario;
use Proveedor;
use ListaProveedores;
use Entrega;
use ListaEntregas;
use matriz_dispersa::MatrizDispersa;

# ==================================================
# VARIABLES GLOBALES DEL SISTEMA
# ==================================================

my $matriz_precios = matriz_dispersa::MatrizDispersa->new();

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

    print "\nMedicamento registrado correctamente\n";
}

# ==================================================
# FUNCION: Mostrar menu principal
# ==================================================
sub mostrar_menu {
    print "\n=================================\n";
    print "   MENU PRINCIPAL - MedTrack\n";
    print "=================================\n";
    print "1. Registrar medicamento manualmente\n";
    print "2. Carga masiva de medicamentos (CSV)\n";
    print "3. Mostrar inventario\n";
    print "4. Buscar medicamento por nombre\n";
    print "5. Mostrar proveedores\n";
    print "6. Generar reportes Graphviz\n";
    print "7. Mostrar matriz dispersa (comparacion de precios)\n";
    print "0. Salir\n";
    print "Seleccione una opcion: ";
}

# ==================================================
# PROGRAMA PRINCIPAL
# ==================================================

print "\n=================================\n";
print "   SISTEMA EDD MedTrack\n";
print "=================================\n";

my $opcion;

do {
    mostrar_menu();
    chomp($opcion = <STDIN>);

    if ($opcion == 1) {
        registrar_medicamento_consola();
    }
    elsif ($opcion == 2) {
        print "\nIngrese la ruta del archivo CSV: ";
        chomp(my $ruta = <STDIN>);
        ListaInventario::carga_masiva($ruta);
    }
    elsif ($opcion == 3) {
        ListaInventario::mostrar();
    }
    elsif ($opcion == 4) {
        print "\nIngrese el nombre del medicamento: ";
        chomp(my $nombre = <STDIN>);

        my $med = ListaInventario::buscar_por_nombre($nombre);

        if ($med) {
            print "\nMedicamento encontrado:\n";
            print "Codigo: $med->{codigo}\n";
            print "Nombre: $med->{nombre}\n";
            print "Cantidad: $med->{cantidad}\n";
            print "Vence: $med->{vencimiento}\n";
        } else {
            print "\nMedicamento no encontrado\n";
        }
    }
    elsif ($opcion == 5) {
        ListaProveedores::mostrar();
    }
    elsif ($opcion == 6) {
        ListaInventario::generar_graphviz();
        ListaProveedores::generar_graphviz();
        print "\nReportes Graphviz generados correctamente\n";
    }
    elsif ($opcion == 7) {
        $matriz_precios->imprimir_lista();
    }
    elsif ($opcion == 0) {
        print "\nSaliendo del sistema...\n";
    }
    else {
        print "\nOpcion invalida\n";
    }

} while ($opcion != 0);

print "\nSistema finalizado correctamente\n";