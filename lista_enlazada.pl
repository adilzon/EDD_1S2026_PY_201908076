#!/usr/bin/perl
use strict;
use warnings;

# Nombre: Adilzon Alfredo Velasquez Hernandez
# Carne: 201908076
# Curso: Estructuras de Datos
# Descripcion: Lista enlazada simple para almacenar canciones

my $head = undef;   # Inicio de la lista


# =========================
# Crear Nodo (Cancion)
# =========================
sub crear_nodo {
    my ($nombre, $artista) = @_;

    my $nuevo_nodo = {
        nombre  => $nombre,
        artista => $artista,
        next    => undef
    };

    return $nuevo_nodo;
}


# =========================
# Insertar Cancion
# =========================
sub insertar_nodo {

    print "Ingrese el nombre de la cancion: ";
    chomp(my $nombre = <STDIN>);

    print "Ingrese el nombre del artista: ";
    chomp(my $artista = <STDIN>);

    if ($nombre eq "" || $artista eq "") {
        print "No se permiten campos vacios.\n";
        return;
    }

    my $nuevo = crear_nodo($nombre, $artista);

    if (!defined $head) {
        $head = $nuevo;
    } else {
        my $actual = $head;
        while (defined $actual->{next}) {
            $actual = $actual->{next};
        }
        $actual->{next} = $nuevo;
    }

    print "Cancion agregada correctamente.\n";
}


# =========================
# Mostrar Lista
# =========================
sub mostrar_lista {

    if (!defined $head) {
        print "La lista de canciones esta vacia.\n";
        return;
    }

    my $actual = $head;

    print "\nLista de Canciones:\n";

    while (defined $actual) {
        print $actual->{nombre} . " - " . $actual->{artista} . " -> ";
        $actual = $actual->{next};
    }

    print "NULL\n";
}


# =========================
# Eliminar Cancion
# =========================
sub eliminar_nodo {

    if (!defined $head) {
        print "La lista esta vacia.\n";
        return;
    }

    print "Ingrese el nombre de la cancion a eliminar: ";
    chomp(my $nombre = <STDIN>);

    if ($head->{nombre} eq $nombre) {
        $head = $head->{next};
        print "Cancion eliminada correctamente.\n";
        return;
    }

    my $actual = $head;

    while (defined $actual->{next} && $actual->{next}->{nombre} ne $nombre) {
        $actual = $actual->{next};
    }

    if (defined $actual->{next}) {
        $actual->{next} = $actual->{next}->{next};
        print "Cancion eliminada correctamente.\n";
    } else {
        print "Cancion no encontrada.\n";
    }
}


# =========================
# Generar Reporte Graphviz
# =========================
sub generar_reporte {

    if (!defined $head) {
        print "La lista esta vacia.\n";
        return;
    }

    open(my $fh, ">", "reporte_canciones.dot") or die "No se pudo crear el archivo.";

    print $fh "digraph ListaCanciones {\n";
    print $fh "rankdir=LR;\n";

    my $actual = $head;
    my $contador = 0;

    while (defined $actual) {

        my $label = $actual->{nombre} . "\\n" . $actual->{artista};

        print $fh "Nodo$contador [shape=box label=\"$label\"];\n";

        if (defined $actual->{next}) {
            my $siguiente = $contador + 1;
            print $fh "Nodo$contador -> Nodo$siguiente;\n";
        }

        $actual = $actual->{next};
        $contador++;
    }

    print $fh "}\n";
    close($fh);

    print "Archivo reporte_canciones.dot generado.\n";
    print "Ejecute: dot -Tpng reporte_canciones.dot -o reporte_canciones.png\n";
}


# =========================
# Menu Principal
# =========================
while (1) {

    print "\n===== MENU LISTA DE CANCIONES =====\n";
    print "1. Agregar cancion\n";
    print "2. Mostrar canciones\n";
    print "3. Eliminar cancion\n";
    print "4. Generar reporte\n";
    print "5. Salir\n";
    print "Seleccione una opcion: ";

    chomp(my $opcion = <STDIN>);

    if ($opcion == 1) {
        insertar_nodo();
    }
    elsif ($opcion == 2) {
        mostrar_lista();
    }
    elsif ($opcion == 3) {
        eliminar_nodo();
    }
    elsif ($opcion == 4) {
        generar_reporte();
    }
    elsif ($opcion == 5) {
        print "Saliendo del sistema...\n";
        last;
    }
    else {
        print "Opcion invalida.\n";
    }
}

