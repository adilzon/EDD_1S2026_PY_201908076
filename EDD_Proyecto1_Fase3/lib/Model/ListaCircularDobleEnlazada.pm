#!/usr/bin/perl
use strict;
use warnings;

package ListaCircularDobleEnlazada;

sub new {
    my $class = shift;
    my $self = {
        cabeza => undef,
        tamano => 0
    };
    bless $self, $class;
    return $self;
}

sub insertar {
    my ($self, $solicitud) = @_;
    if (!defined $self->{cabeza}) {
        $self->{cabeza} = $solicitud;
        $solicitud->{siguiente} = $solicitud;
        $solicitud->{anterior}  = $solicitud;
        $self->{tamano} = 1;
        return;
    }
    my $ultimo = $self->{cabeza}->{anterior};
    $ultimo->{siguiente} = $solicitud;
    $solicitud->{anterior} = $ultimo;
    $solicitud->{siguiente} = $self->{cabeza};
    $self->{cabeza}->{anterior} = $solicitud;
    $self->{tamano}++;
}

sub procesar_primera {
    my $self = shift;
    return undef unless defined $self->{cabeza};
    return $self->{cabeza};
}

sub eliminar_primera {
    my $self = shift;
    return unless defined $self->{cabeza};
    if ($self->{tamano} == 1) {
        $self->{cabeza} = undef;
        $self->{tamano} = 0;
        return;
    }
    my $primera = $self->{cabeza};
    my $ultima  = $primera->{anterior};
    $self->{cabeza} = $primera->{siguiente};
    $self->{cabeza}->{anterior} = $ultima;
    $ultima->{siguiente} = $self->{cabeza};
    $self->{tamano}--;
}

sub mostrar_todos {
    my $self = shift;
    return if !defined $self->{cabeza};
    print "=== SOLICITUDES PENDIENTES ===\n";
    my $actual = $self->{cabeza};
    do {
        print "No. " . $actual->obtener_numero . " | Dept: " . $actual->obtener_departamento .
              " | Med: " . $actual->obtener_codigo_medicamento .
              " | Cant: " . $actual->obtener_cantidad .
              " | Estado: " . $actual->obtener_estado . "\n";
        $actual = $actual->{siguiente};
    } while ($actual != $self->{cabeza});
    print "Total pendientes: " . $self->{tamano} . "\n\n";
}

1;