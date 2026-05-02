package NodoCabecera;

use strict;
use warnings;

# =============================================
# CONSTRUCTOR
# =============================================
sub new {
    my ($class, $label) = @_;

    my $self = {
        label => $label,   # identificador
        right => undef,    # primer NodoDato de la fila
        down  => undef,    # primer NodoDato de la columna
        next  => undef,    # siguiente cabecera
    };

    bless $self, $class;
    return $self;
}

# =============================================
# GETTERS
# =============================================
sub get_label { return $_[0]->{label}; }
sub get_right { return $_[0]->{right}; }
sub get_down  { return $_[0]->{down}; }
sub get_next  { return $_[0]->{next}; }

# =============================================
# SETTERS
# =============================================
sub set_right {
    my ($self, $nodo) = @_;
    $self->{right} = $nodo;
}

sub set_down {
    my ($self, $nodo) = @_;
    $self->{down} = $nodo;
}

sub set_next {
    my ($self, $nodo) = @_;
    $self->{next} = $nodo;
}

# =============================================
# DEBUG
# =============================================
sub to_string {
    my ($self) = @_;

    my $r = defined($self->{right}) ? "Si" : "No";
    my $d = defined($self->{down})  ? "Si" : "No";
    my $n = defined($self->{next})  ? "Si" : "No";

    return "NodoCabecera [ label=$self->{label}, right=$r, down=$d, next=$n ]";
}

1;