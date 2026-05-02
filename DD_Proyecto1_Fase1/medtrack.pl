#!/usr/bin/perl
use strict;
use warnings;

use lib 'lib';
use Medicamento;
use ListaDobleEnlazada;
use MatrizDispersa;
use ListaCircularDobleEnlazada;
use ListaCircularListas;
use Solicitud;
use Proveedor;

my $lista_inventario   = ListaDobleEnlazada->new();
my $matriz_precios     = MatrizDispersa->new(20, 20);
# ===== MATRIZ (MAPEO) =====
my %map_medicamentos;
my %map_laboratorios;
my $fila_actual = 0;
my $col_actual  = 0;
my $lista_solicitudes  = ListaCircularDobleEnlazada->new();
my $lista_proveedores  = ListaCircularListas->new();

my $contador_solicitudes = 1;

print "=====================================\n";
print "    BIENVENIDO A EDD MEDTRACK\n";
print "=====================================\n\n";

my $opcion;

do {
    print "1. Modo Administrador (farmacia)\n";
    print "2. Modo Usuario Departamental\n";
    print "3. Salir\n\n";
    print "Elige una opcion (1-3): ";

    chomp($opcion = <STDIN>);

    if ($opcion == 1) {
        menu_administrador();
    }
    elsif ($opcion == 2) {
        menu_usuario_departamental();
    }
    elsif ($opcion == 3) {
        print "\nGracias por usar EDD MedTrack. Hasta pronto.\n";
    }
    else {
        print "\nOpcion invalida. Intenta de nuevo.\n\n";
    }

} while ($opcion != 3);

print "Programa finalizado.\n";

# =============================================
# MENU ADMINISTRADOR
# =============================================
sub menu_administrador {
    my $op_admin;
    do {
        print "\n--- MENU ADMINISTRADOR ---\n";
        print "1. Registrar Medicamento (individual)\n";
        print "2. Carga Masiva de Medicamentos (CSV)\n";
        print "3. Mostrar Inventario Completo\n";
        print "4. Procesar Solicitudes de Reabastecimiento\n";
        print "5. Gestionar Proveedores\n";
        print "6. Registrar Entrega de Proveedor\n";
        print "7. Consultar inventario por laboratorio/medicina\n";
        print "8. Generar Reportes Gráficos (Graphviz)\n";
        print "9. Volver al menu principal\n\n";
        print "Elige una opcion (1-9): ";

        chomp($op_admin = <STDIN>);

        if ($op_admin == 1) { registrar_medicamento(); }
        elsif ($op_admin == 2) { carga_masiva_medicamentos(); }
        elsif ($op_admin == 3) { $lista_inventario->mostrar_todos(); }
        elsif ($op_admin == 4) { procesar_solicitudes(); }
        elsif ($op_admin == 5) { gestionar_proveedores(); }
        elsif ($op_admin == 6) { registrar_entrega_proveedor(); }
        elsif ($op_admin == 7) { consultar_matriz(); }
        elsif ($op_admin == 8) { generar_reportes(); }
        elsif ($op_admin == 9) { print "\nVolviendo al menu principal...\n"; }
        else { print "\nOpcion invalida.\n"; }

    } while ($op_admin != 9);
}

# =============================================
# MENU USUARIO
# =============================================
sub menu_usuario_departamental {
    print "\n--- INICIO DE SESION USUARIO ---\n";
    print "Codigo de departamento: ";
    chomp(my $dept = <STDIN>);
    print "Contrasena: ";
    chomp(my $pass = <STDIN>);

    if ($dept eq "DEP001" && $pass eq "1234") {
        print "Bienvenido, Departamento DEP001\n\n";
        menu_usuario_logueado($dept);
    } else {
        print "Credenciales incorrectas.\n\n";
    }
}

sub menu_usuario_logueado {
    my $departamento = shift;
    my $op_user;
    do {
        print "\n--- MENU USUARIO DEP001 ---\n";
        print "1. Consultar Disponibilidad de Medicamentos\n";
        print "2. Solicitar Reabastecimiento\n";
        print "3. Visualizar Historial de Solicitudes\n";
        print "4. Cerrar Sesion\n\n";
        print "Elige una opcion (1-4): ";

        chomp($op_user = <STDIN>);

        if ($op_user == 1) { consultar_disponibilidad(); }
        elsif ($op_user == 2) { solicitar_reabastecimiento($departamento); }
        elsif ($op_user == 3) { visualizar_historial($departamento); }
        elsif ($op_user == 4) { print "\nSesion cerrada.\n"; }
        else { print "\nOpcion invalida.\n"; }

    } while ($op_user != 4);
}

# =============================================
# FUNCIONES ADMINISTRADOR
# =============================================
sub registrar_medicamento {
    print "\n--- REGISTRAR MEDICAMENTO ---\n";
    print "Codigo: "; chomp(my $codigo = <STDIN>);
    print "Nombre comercial: "; chomp(my $nombre = <STDIN>);
    print "Principio activo: "; chomp(my $principio = <STDIN>);
    print "Laboratorio: "; chomp(my $lab = <STDIN>);
    print "Precio: "; chomp(my $precio = <STDIN>);
    print "Cantidad en stock: "; chomp(my $cantidad = <STDIN>);
    print "Fecha vencimiento (YYYY-MM-DD): "; chomp(my $fecha = <STDIN>);
    print "Nivel minimo: "; chomp(my $nivel = <STDIN>);

    my $nuevo = Medicamento->new($codigo, $nombre, $principio, $lab, $precio, $cantidad, $fecha, $nivel);
    $lista_inventario->insertar_ordenado($nuevo);
    # ===== GUARDAR EN MATRIZ =====

if (!exists $map_medicamentos{$nombre}) {
    $map_medicamentos{$nombre} = $fila_actual++;
}

if (!exists $map_laboratorios{$lab}) {
    $map_laboratorios{$lab} = $col_actual++;
}

my $fila = $map_medicamentos{$nombre};
my $col  = $map_laboratorios{$lab};

my $valor = {
    precio   => $precio,
    cantidad => $cantidad
};

$matriz_precios->insertar($fila, $col, $valor);
    print "Medicamento registrado correctamente.\n\n";
}

sub carga_masiva_medicamentos {
    print "\n--- CARGA MASIVA ---\n";
    print "Ruta del archivo CSV: ";
    chomp(my $ruta = <STDIN>);
    $ruta = 'data/medicamentos_prueba.csv' if $ruta eq '';

    if (! -e $ruta) {
        print "Error: No se encontro el archivo.\n\n";
        return;
    }

    open my $fh, '<', $ruta or die "No se pudo abrir $ruta: $!";
    my $linea = <$fh>; # saltar encabezado
    my $contador = 0;

    while (my $linea = <$fh>) {
        chomp $linea;
        next if $linea eq '';

        my @campos = split /,/, $linea;
        @campos = map { s/^\s+|\s+$//g; $_ } @campos;

        if (@campos >= 8) {

            my ($codigo, $nombre, $principio, $lab, $precio, $cantidad, $fecha, $nivel) = @campos;

            my $nuevo = Medicamento->new(@campos[0..7]);
            $lista_inventario->insertar_ordenado($nuevo);

            # ===== INSERTAR EN MATRIZ =====

            if (!exists $map_medicamentos{$nombre}) {
                $map_medicamentos{$nombre} = $fila_actual++;
            }

            if (!exists $map_laboratorios{$lab}) {
                $map_laboratorios{$lab} = $col_actual++;
            }

            my $fila = $map_medicamentos{$nombre};
            my $col  = $map_laboratorios{$lab};

            my $valor = {
                precio   => $precio,
                cantidad => $cantidad
            };

            $matriz_precios->insertar($fila, $col, $valor);

            $contador++;
        }
    }

    close $fh;
    print "Carga masiva completada. $contador medicamentos agregados.\n\n";
}

sub procesar_solicitudes {
    my $primera = $lista_solicitudes->procesar_primera();
    if (!defined $primera) {
        print "No hay solicitudes pendientes.\n\n";
        return;
    }
    print "\nSolicitud a procesar:\n";
    print "No. " . $primera->obtener_numero . " | Dept: " . $primera->obtener_departamento .
          " | Med: " . $primera->obtener_codigo_medicamento . " | Cant: " . $primera->obtener_cantidad . "\n";
    print "1. Aprobar\n2. Rechazar\nElige: ";
    chomp(my $accion = <STDIN>);

    if ($accion == 1) {
        $primera->cambiar_estado("aprobada");
        print "Solicitud aprobada.\n";
    } elsif ($accion == 2) {
        $primera->cambiar_estado("rechazada");
        print "Solicitud rechazada.\n";
    }
    $lista_solicitudes->eliminar_primera();
    print "Solicitud procesada.\n\n";
}

sub gestionar_proveedores {
    print "\n--- GESTIONAR PROVEEDORES ---\n";
    print "1. Registrar nuevo proveedor\n";
    print "2. Mostrar todos los proveedores\n";
    print "Elige: ";
    chomp(my $accion = <STDIN>);

    if ($accion == 1) {
        print "NIT: "; chomp(my $nit = <STDIN>);
        print "Nombre empresa: "; chomp(my $nombre = <STDIN>);
        print "Contacto principal: "; chomp(my $contacto = <STDIN>);
        print "Telefono: "; chomp(my $telefono = <STDIN>);
        print "Direccion: "; chomp(my $direccion = <STDIN>);

        my $nuevo_prov = Proveedor->new($nit, $nombre, $contacto, $telefono, $direccion);
        $lista_proveedores->insertar_proveedor($nuevo_prov);
        print "Proveedor registrado.\n\n";
    } elsif ($accion == 2) {
        $lista_proveedores->mostrar_todos();
    }
}

sub registrar_entrega_proveedor {
    print "\n--- REGISTRAR ENTREGA DE PROVEEDOR ---\n";
    print "NIT del proveedor: ";
    chomp(my $nit = <STDIN>);
    my $prov = $lista_proveedores->buscar_proveedor($nit);
    if (!defined $prov) {
        print "Proveedor no encontrado.\n\n";
        return;
    }
    print "Fecha de entrega (YYYY-MM-DD): ";
    chomp(my $fecha = <STDIN>);
    print "Numero de factura: ";
    chomp(my $factura = <STDIN>);
    print "Codigo de medicamento: ";
    chomp(my $codigo = <STDIN>);
    print "Cantidad entregada: ";
    chomp(my $cantidad = <STDIN>);

    $prov->agregar_entrega($fecha, $factura, $codigo, $cantidad);
    print "Entrega registrada correctamente.\n\n";
}

# =============================================
# FUNCIONES USUARIO
# =============================================
sub consultar_disponibilidad {
    print "\n--- CONSULTAR DISPONIBILIDAD ---\n";
    $lista_inventario->mostrar_todos();
}

sub solicitar_reabastecimiento {
    my $departamento = shift;
    print "\n--- SOLICITAR REABASTECIMIENTO ---\n";
    print "Codigo de medicamento: ";
    chomp(my $codigo = <STDIN>);
    print "Cantidad requerida: ";
    chomp(my $cantidad = <STDIN>);
    print "Prioridad (urgente/alta/media/baja): ";
    chomp(my $prioridad = <STDIN>);
    print "Justificacion: ";
    chomp(my $just = <STDIN>);

    my $nueva_solicitud = Solicitud->new(
        $contador_solicitudes++,
        $departamento,
        $codigo,
        $cantidad,
        $prioridad,
        $just
    );

    $lista_solicitudes->insertar($nueva_solicitud);
    print "Solicitud No. " . ($contador_solicitudes-1) . " creada correctamente.\n\n";
}

sub visualizar_historial {
    my $departamento = shift;
    print "\n--- HISTORIAL DE SOLICITUDES DEL DEPARTAMENTO $departamento ---\n";
    $lista_solicitudes->mostrar_todos();
}

# =============================================
# GENERAR REPORTES (VERSIÓN FINAL - MEJORADA)
# =============================================
sub generar_reportes {
    my $dir = "reports";
    mkdir $dir unless -d $dir;

    print "\n=== GENERANDO REPORTES CON GRAPHVIZ ===\n";

    # 1. Inventario (con 3 colores y fecha correcta)
    open my $dot1, '>', "$dir/inventario.dot" or die "Error creando inventario.dot";
    print $dot1 "digraph Inventario {\n    rankdir=LR;\n    node [shape=box, style=filled, fontsize=10];\n";
    if (defined $lista_inventario->{cabeza}) {
        my $actual = $lista_inventario->{cabeza};
        while (defined $actual) {
            my $cant  = $actual->obtener_cantidad;
            my $nivel = $actual->obtener_nivel_minimo;
            my $color = ($cant < $nivel) ? "red" : ($cant < $nivel * 1.5) ? "yellow" : "lightgreen";

            print $dot1 "    \"" . $actual->obtener_codigo . "\" [label=\"" .
                  $actual->obtener_codigo . "\\n" .
                  $actual->obtener_nombre . "\\n" .
                  "Cant: " . $cant . "\\n" .
                  "Venc: " . $actual->obtener_fecha_vencimiento .
                  "\", fillcolor=\"" . $color . "\"];\n";

            if (defined $actual->{siguiente}) {
                print $dot1 "    \"" . $actual->obtener_codigo . "\" -> \"" .
                      $actual->{siguiente}->obtener_codigo . "\" [dir=both];\n";
            }
            $actual = $actual->{siguiente};
        }
    }
    print $dot1 "}\n";
    close $dot1;
    system("dot -Tpng $dir/inventario.dot -o $dir/inventario.png");

# =========================
# 2. SOLICITUDES (CORREGIDO PERFECTO)
# =========================
open my $dot2, '>', "$dir/solicitudes.dot" or die "Error creando solicitudes.dot";

print $dot2 "digraph Solicitudes {\n";
print $dot2 "    rankdir=LR;\n";
print $dot2 "    node [shape=circle, style=filled, fillcolor=lightyellow, fontsize=10];\n\n";

my $contador = 0;

if (defined $lista_solicitudes->{cabeza}) {

    my $s = $lista_solicitudes->{cabeza};

    # ===== CREAR NODOS =====
    do {
        $contador++;

        print $dot2 "    \"" . $s->obtener_numero . "\" [label=\"" .
            "No: " . $s->obtener_numero . "\\n" .
            "Dept: " . $s->obtener_departamento . "\\n" .
            "Med: " . $s->obtener_codigo_medicamento . "\\n" .
            "Cant: " . $s->obtener_cantidad . "\\n" .
            "Prioridad: " . $s->obtener_prioridad .
            "\"];\n";

        $s = $s->{siguiente};

    } while ($s != $lista_solicitudes->{cabeza});

    # ===== CONEXIONES DOBLES (REALMENTE DOBLES) =====
    $s = $lista_solicitudes->{cabeza};

    do {
        # siguiente
        print $dot2 "    \"" . $s->obtener_numero . "\" -> \"" .
            $s->{siguiente}->obtener_numero . "\";\n";

        # anterior
        print $dot2 "    \"" . $s->obtener_numero . "\" -> \"" .
            $s->{anterior}->obtener_numero . "\";\n";

        $s = $s->{siguiente};

    } while ($s != $lista_solicitudes->{cabeza});
}

# ===== CONTADOR =====
print $dot2 "\n    total [shape=box, fillcolor=lightblue, label=\"Total Solicitudes: $contador\"];\n";

print $dot2 "}\n";
close $dot2;

system("dot -Tpng $dir/solicitudes.dot -o $dir/solicitudes.png");

    # 3. Proveedores (diseño más parecido a la referencia)
    open my $dot3, '>', "$dir/proveedores.dot" or die "Error creando proveedores.dot";
    print $dot3 "digraph Proveedores {\n";
    print $dot3 "    rankdir=TB;\n";
    print $dot3 "    node [shape=box, style=filled];\n";

    if (defined $lista_proveedores->{cabeza}) {
        my $p = $lista_proveedores->{cabeza};
        my $first = $p;
        do {
            print $dot3 "    \"" . $p->obtener_nit . "\" [label=\"NIT: " . $p->obtener_nit .
                  "\\n" . $p->obtener_nombre . "\", fillcolor=lightblue];\n";

            my $lista_id = $p->obtener_nit . "_lista";
            print $dot3 "    \"" . $lista_id . "\" [label=\"Lista\", fillcolor=lightgray];\n";
            print $dot3 "    \"" . $p->obtener_nit . "\" -> \"" . $lista_id . "\";\n";

            my $e = 0;
            foreach my $entrega (@{$p->{entregas}}) {
                $e++;
                my $id = $p->obtener_nit . "_e" . $e;
                print $dot3 "    \"" . $id . "\" [label=\"Factura: " . $entrega->{factura} .
                      "\\nMed: " . $entrega->{codigo_medicamento} .
                      "\\nCant: " . $entrega->{cantidad} . "\"];\n";
                print $dot3 "    \"" . $lista_id . "\" -> \"" . $id . "\";\n";
            }

            if (defined $p->{siguiente} && $p->{siguiente} != $first) {
                print $dot3 "    \"" . $p->obtener_nit . "\" -> \"" . $p->{siguiente}->obtener_nit . "\" [style=dashed, color=blue];\n";
            }
            $p = $p->{siguiente};
        } while ($p != $first);
    }
    print $dot3 "}\n";
    close $dot3;
    system("dot -Tpng $dir/proveedores.dot -o $dir/proveedores.png");

# =========================================
# 4. MATRIZ DISPERSA (VISUAL REAL)
# =========================================
open my $dot4, '>', "$dir/matriz.dot" or die "Error creando matriz.dot";

print $dot4 "digraph Matriz {\n";
print $dot4 "    node [shape=box, style=filled, fillcolor=lightcyan];\n";
print $dot4 "    rankdir=LR;\n\n";

# Nodo raíz
print $dot4 "    raiz [label=\"Matriz\\nTotal: $matriz_precios->{total_datos}\", fillcolor=lightblue];\n";

# =========================
# CABECERAS DE FILAS
# =========================
my $fila = $matriz_precios->{lista_filas};
while ($fila) {
    print $dot4 "    fila_" . $fila->get_label() . " [label=\"F" . $fila->get_label() . "\", fillcolor=lightgreen];\n";
    print $dot4 "    raiz -> fila_" . $fila->get_label() . ";\n";

    my $nodo = $fila->get_right();

    while ($nodo) {
        my $id = "n_" . $nodo->get_fila() . "_" . $nodo->get_col();
        my $v = $nodo->get_valor();

        print $dot4 "    $id [label=\"(" . $nodo->get_fila() . "," . $nodo->get_col() .
              ")\\nQ$v->{precio}\\nStock:$v->{cantidad}\"];\n";

        print $dot4 "    fila_" . $fila->get_label() . " -> $id;\n";

        if ($nodo->get_right()) {
            my $next_id = "n_" . $nodo->get_right()->get_fila() . "_" . $nodo->get_right()->get_col();
            print $dot4 "    $id -> $next_id;\n";
        }

        $nodo = $nodo->get_right();
    }

    $fila = $fila->get_next();
}

print $dot4 "}\n";
close $dot4;

system("dot -Tpng $dir/matriz.dot -o $dir/matriz.png");

    print "Reportes generados correctamente en la carpeta 'reports/'\n";
    print "Archivos: inventario.png, solicitudes.png, proveedores.png, matriz.png\n\n";
}

sub consultar_matriz {

    print "\n--- CONSULTA POR MEDICAMENTO ---\n";
    print "Nombre o codigo del medicamento: ";
    chomp(my $input = <STDIN>);

    my $nombre_encontrado = undef;

    # Buscar por nombre o código
    foreach my $nombre (keys %map_medicamentos) {
        if (lc($nombre) eq lc($input)) {
            $nombre_encontrado = $nombre;
            last;
        }
    }

    # Buscar por código en inventario
    if (!defined $nombre_encontrado) {
        my $actual = $lista_inventario->{cabeza};
        while ($actual) {
            if (lc($actual->obtener_codigo) eq lc($input)) {
                $nombre_encontrado = $actual->obtener_nombre;
                last;
            }
            $actual = $actual->{siguiente};
        }
    }

    if (!defined $nombre_encontrado) {
        print "No existe ese medicamento.\n\n";
        return;
    }

    my $fila = $map_medicamentos{$nombre_encontrado};

    print "\nRESULTADOS PARA: $nombre_encontrado\n";

    foreach my $lab (keys %map_laboratorios) {
        my $col = $map_laboratorios{$lab};
        my $nodo = $matriz_precios->obtener($fila, $col);

        if ($nodo) {
            my $v = $nodo->get_valor();
            print "Lab: $lab | Precio: Q$v->{precio} | Stock: $v->{cantidad}\n";
        }
    }

    print "\n";
}