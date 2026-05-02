#!/usr/bin/perl
use strict;
use warnings;

package MatrizDispersa;

use NodoCabecera;
use NodoDato;

# =============================================
# CONSTRUCTOR
# =============================================
sub new {
    my ($class, $num_filas, $num_cols) = @_;

    my $self = {
        lista_filas => undef,
        lista_cols  => undef,
        num_filas   => $num_filas,
        num_cols    => $num_cols,
        total_datos => 0,
    };

    bless $self, $class;
    return $self;
}

# =============================================
# BUSQUEDA DE CABECERAS
# =============================================
sub _buscar_cab_fila {
    my ($self, $fila_idx) = @_;

    my $actual = $self->{lista_filas};
    while (defined $actual) {
        return $actual if ($actual->get_label() == $fila_idx);
        last if ($actual->get_label() > $fila_idx);
        $actual = $actual->get_next();
    }
    return undef;
}

sub _buscar_cab_col {
    my ($self, $col_idx) = @_;

    my $actual = $self->{lista_cols};
    while (defined $actual) {
        return $actual if ($actual->get_label() == $col_idx);
        last if ($actual->get_label() > $col_idx);
        $actual = $actual->get_next();
    }
    return undef;
}

# =============================================
# CREAR CABECERAS
# =============================================
sub _obtener_o_crear_cab_fila {
    my ($self, $fila_idx) = @_;

    if (!defined $self->{lista_filas}) {
        my $nueva = NodoCabecera->new($fila_idx);
        $self->{lista_filas} = $nueva;
        return $nueva;
    }

    if ($self->{lista_filas}->get_label() > $fila_idx) {
        my $nueva = NodoCabecera->new($fila_idx);
        $nueva->set_next($self->{lista_filas});
        $self->{lista_filas} = $nueva;
        return $nueva;
    }

    if ($self->{lista_filas}->get_label() == $fila_idx) {
        return $self->{lista_filas};
    }

    my $anterior = $self->{lista_filas};
    my $actual   = $anterior->get_next();

    while (defined $actual) {
        if ($actual->get_label() == $fila_idx) {
            return $actual;
        }
        if ($actual->get_label() > $fila_idx) {
            my $nueva = NodoCabecera->new($fila_idx);
            $nueva->set_next($actual);
            $anterior->set_next($nueva);
            return $nueva;
        }
        $anterior = $actual;
        $actual   = $actual->get_next();
    }

    my $nueva = NodoCabecera->new($fila_idx);
    $anterior->set_next($nueva);
    return $nueva;
}

sub _obtener_o_crear_cab_col {
    my ($self, $col_idx) = @_;

    if (!defined $self->{lista_cols}) {
        my $nueva = NodoCabecera->new($col_idx);
        $self->{lista_cols} = $nueva;
        return $nueva;
    }

    if ($self->{lista_cols}->get_label() > $col_idx) {
        my $nueva = NodoCabecera->new($col_idx);
        $nueva->set_next($self->{lista_cols});
        $self->{lista_cols} = $nueva;
        return $nueva;
    }

    if ($self->{lista_cols}->get_label() == $col_idx) {
        return $self->{lista_cols};
    }

    my $anterior = $self->{lista_cols};
    my $actual   = $anterior->get_next();

    while (defined $actual) {
        if ($actual->get_label() == $col_idx) {
            return $actual;
        }
        if ($actual->get_label() > $col_idx) {
            my $nueva = NodoCabecera->new($col_idx);
            $nueva->set_next($actual);
            $anterior->set_next($nueva);
            return $nueva;
        }
        $anterior = $actual;
        $actual   = $actual->get_next();
    }

    my $nueva = NodoCabecera->new($col_idx);
    $anterior->set_next($nueva);
    return $nueva;
}

# =============================================
# INSERTAR
# =============================================
sub insertar {
    my ($self, $fila, $col, $valor) = @_;

    if ($fila < 0 || $col < 0) {
        print "[ERROR] Índices inválidos\n";
        return;
    }

    # expandir dimensiones
    $self->{num_filas} = $fila + 1 if ($fila >= $self->{num_filas});
    $self->{num_cols}  = $col + 1  if ($col  >= $self->{num_cols});

    my $cab_fila = $self->_obtener_o_crear_cab_fila($fila);
    my $cab_col  = $self->_obtener_o_crear_cab_col($col);

    # verificar si ya existe
    my $existente = $self->obtener($fila, $col);
    if (defined $existente) {
        $existente->set_valor($valor);
        return;
    }

    my $nuevo = NodoDato->new($fila, $col, $valor);

    # ===== INSERTAR EN FILA =====
    if (!defined $cab_fila->get_right()) {
        $cab_fila->set_right($nuevo);
    }
    elsif ($cab_fila->get_right()->get_col() > $col) {
        my $primero = $cab_fila->get_right();
        $nuevo->set_right($primero);
        $primero->set_left($nuevo);
        $cab_fila->set_right($nuevo);
    }
    else {
        my $anterior = $cab_fila->get_right();
        my $actual   = $anterior->get_right();

        while (defined $actual && $actual->get_col() < $col) {
            $anterior = $actual;
            $actual   = $actual->get_right();
        }

        $nuevo->set_right($actual);
        $nuevo->set_left($anterior);
        $anterior->set_right($nuevo);

        if (defined $actual) {
            $actual->set_left($nuevo);
        }
    }

    # ===== INSERTAR EN COLUMNA =====
    if (!defined $cab_col->get_down()) {
        $cab_col->set_down($nuevo);
    }
    elsif ($cab_col->get_down()->get_fila() > $fila) {
        my $primero = $cab_col->get_down();
        $nuevo->set_down($primero);
        $primero->set_up($nuevo);
        $cab_col->set_down($nuevo);
    }
    else {
        my $anterior = $cab_col->get_down();
        my $actual   = $anterior->get_down();

        while (defined $actual && $actual->get_fila() < $fila) {
            $anterior = $actual;
            $actual   = $actual->get_down();
        }

        $nuevo->set_down($actual);
        $nuevo->set_up($anterior);
        $anterior->set_down($nuevo);

        if (defined $actual) {
            $actual->set_up($nuevo);
        }
    }

    $self->{total_datos}++;
}

# =============================================
# OBTENER
# =============================================
sub obtener {
    my ($self, $fila, $col) = @_;

    my $cab_fila = $self->_buscar_cab_fila($fila);
    return undef unless defined $cab_fila;

    my $actual = $cab_fila->get_right();

    while (defined $actual) {
        return $actual if ($actual->get_col() == $col);
        last if ($actual->get_col() > $col);
        $actual = $actual->get_right();
    }

    return undef;
}

# =============================================
# IMPRESION
# =============================================
sub imprimir_lista {
    my ($self) = @_;

    print "\n--- MATRIZ DISPERSA ---\n";
    print "Total elementos: $self->{total_datos}\n\n";

    if (!defined $self->{lista_filas}) {
        print "(matriz vacía)\n";
        return;
    }

    my $cab_fila = $self->{lista_filas};

    while (defined $cab_fila) {
        my $f = $cab_fila->get_label();
        print "Fila $f:\n";

        my $nodo = $cab_fila->get_right();

        while (defined $nodo) {
            my $c = $nodo->get_col();
            my $v = $nodo->get_valor();

            if (ref($v) eq 'HASH') {
                print "  ($f,$c) => Lab: $v->{laboratorio}, Precio: $v->{precio}\n";
            } else {
                print "  ($f,$c) => $v\n";
            }

            $nodo = $nodo->get_right();
        }

        $cab_fila = $cab_fila->get_next();
    }

    print "------------------------\n";
}

1;