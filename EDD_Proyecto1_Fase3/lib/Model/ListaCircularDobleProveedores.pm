#!/usr/bin/perl
use strict;
use warnings;

package ListaCircularDobleProveedores;

sub new {
    my $class = shift;
    my $self = {
        cabeza => undef,
        tamano => 0
    };
    bless $self, $class;
    return $self;
}

sub insertar_proveedor {
    my ($self, $proveedor) = @_;

    if (!defined $self->{cabeza}) {
        $self->{cabeza} = $proveedor;
        $proveedor->{siguiente} = $proveedor;
        $proveedor->{anterior}  = $proveedor;
        $self->{tamano} = 1;
        return;
    }

    my $ultimo = $self->{cabeza}->{anterior};
    $ultimo->{siguiente} = $proveedor;
    $proveedor->{anterior} = $ultimo;
    $proveedor->{siguiente} = $self->{cabeza};
    $self->{cabeza}->{anterior} = $proveedor;

    $self->{tamano}++;
}

sub buscar_proveedor {
    my ($self, $nit) = @_;
    return undef unless defined $self->{cabeza};

    my $actual = $self->{cabeza};
    do {
        return $actual if $actual->obtener_nit eq $nit;
        $actual = $actual->{siguiente};
    } while ($actual != $self->{cabeza});

    return undef;
}

sub mostrar_todos {
    my $self = shift;
    return unless defined $self->{cabeza};

    print "=== PROVEEDORES (Lista Circular Doble) ===\n";
    my $actual = $self->{cabeza};
    do {
        print "NIT: " . $actual->obtener_nit . " | " . $actual->obtener_nombre . "\n";
        $actual->mostrar_entregas();
        print "----------------\n";
        $actual = $actual->{siguiente};
    } while ($actual != $self->{cabeza});
    print "Total proveedores: " . $self->{tamano} . "\n\n";
}

sub obtener_cabeza { $_[0]->{cabeza} }
sub obtener_tamano { $_[0]->{tamano} }

sub generar_dot {
    my ($self, $archivo) = @_;

    open(my $fh, '>', $archivo) or die "No se pudo crear $archivo: $!";

    print $fh "digraph ListaCircular {\n";
    print $fh "    rankdir=LR;\n";
    print $fh "    node [shape=box, style=filled, color=lightyellow];\n\n";

    return unless defined $self->{cabeza};

    my $actual = $self->{cabeza};
    my $i = 0;

    do {
        my $id = "P$i";

        print $fh "$id [label=\"".
                  $actual->obtener_nit."\\n".
                  $actual->obtener_nombre."\"];\n";

        my $sig = "P" . (($i + 1) % $self->{tamano});

        print $fh "$id -> $sig;\n";

        $actual = $actual->{siguiente};
        $i++;

    } while ($actual != $self->{cabeza});

    print $fh "}\n";
    close($fh);

    print "✅ Reporte proveedores generado\n";
}

1;