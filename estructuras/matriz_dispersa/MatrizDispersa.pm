package matriz_dispersa::MatrizDispersa;

use strict;
use warnings;

use matriz_dispersa::NodoCabecera;
use matriz_dispersa::NodoDato;

# CONSTRUCTOR
sub new {
    my ($class) = @_;
    my $self = {
        lista_filas => undef,   # Laboratorios
        lista_cols  => undef,   # Medicamentos
        num_filas   => 0,
        num_cols    => 0,
        total_datos => 0,
    };
    bless $self, $class;
    return $self;
}

# ================== CABECERAS ==================

sub _obtener_o_crear_cab {
    my ($self, $lista, $idx) = @_;
    return $$lista = matriz_dispersa::NodoCabecera->new($idx)
        unless defined $$lista;

    if ($$lista->get_label() > $idx) {
        my $nueva = matriz_dispersa::NodoCabecera->new($idx);
        $nueva->set_next($$lista);
        $$lista = $nueva;
        return $nueva;
    }

    my $actual = $$lista;
    while ($actual) {
        return $actual if $actual->get_label() == $idx;
        last if !$actual->get_next() || $actual->get_next()->get_label() > $idx;
        $actual = $actual->get_next();
    }

    my $nueva = matriz_dispersa::NodoCabecera->new($idx);
    $nueva->set_next($actual->get_next());
    $actual->set_next($nueva);
    return $nueva;
}

# ================== INSERTAR ==================

sub insertar {
    my ($self, $fila, $col, $valor) = @_;

    my $cab_fila = $self->_obtener_o_crear_cab(\$self->{lista_filas}, $fila);
    my $cab_col  = $self->_obtener_o_crear_cab(\$self->{lista_cols},  $col);

    $self->{num_filas} = $fila + 1 if $fila >= $self->{num_filas};
    $self->{num_cols}  = $col  + 1 if $col  >= $self->{num_cols};

    my $nuevo = matriz_dispersa::NodoDato->new($fila, $col, $valor);

    # Horizontal (fila)
    if (!$cab_fila->get_right()) {
        $cab_fila->set_right($nuevo);
    } else {
        my $act = $cab_fila->get_right();
        my $prev;
        while ($act && $act->get_col() < $col) {
            $prev = $act;
            $act = $act->get_right();
        }
        if ($prev) {
            $prev->set_right($nuevo);
            $nuevo->set_left($prev);
        } else {
            $cab_fila->set_right($nuevo);
        }
        if ($act) {
            $nuevo->set_right($act);
            $act->set_left($nuevo);
        }
    }

    # Vertical (columna)
    if (!$cab_col->get_down()) {
        $cab_col->set_down($nuevo);
    } else {
        my $act = $cab_col->get_down();
        my $prev;
        while ($act && $act->get_fila() < $fila) {
            $prev = $act;
            $act = $act->get_down();
        }
        if ($prev) {
            $prev->set_down($nuevo);
            $nuevo->set_up($prev);
        } else {
            $cab_col->set_down($nuevo);
        }
        if ($act) {
            $nuevo->set_down($act);
            $act->set_up($nuevo);
        }
    }

    $self->{total_datos}++;
}

# ================== MOSTRAR ==================

sub imprimir {
    my ($self) = @_;

    print "\n--- MATRIZ DISPERSA (Comparación de Precios) ---\n";

    my $fila = $self->{lista_filas};
    while ($fila) {
        my $nodo = $fila->get_right();
        while ($nodo) {
            my $v = $nodo->get_valor();
            print "Lab $fila->{label} | Med $nodo->{col} -> ";
            print "Q$v->{precio} | Cant: $v->{cantidad} | Vence: $v->{fecha_ven}\n";
            $nodo = $nodo->get_right();
        }
        $fila = $fila->get_next();
    }
}

1;