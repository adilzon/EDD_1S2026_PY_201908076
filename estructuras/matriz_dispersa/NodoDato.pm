package matriz_dispersa::NodoDato;

use strict;
use warnings;

sub new {
    my ($class, $fila, $col, $valor) = @_;
    my $self = {
        fila  => $fila,
        col   => $col,
        valor => $valor,   # HASH con info del medicamento
        left  => undef,
        right => undef,
        up    => undef,
        down  => undef,
    };
    bless $self, $class;
    return $self;
}

sub get_fila  { $_[0]->{fila} }
sub get_col   { $_[0]->{col} }
sub get_valor { $_[0]->{valor} }
sub set_valor { $_[0]->{valor} = $_[1] }

sub get_left  { $_[0]->{left} }
sub set_left  { $_[0]->{left} = $_[1] }

sub get_right { $_[0]->{right} }
sub set_right { $_[0]->{right} = $_[1] }

sub get_up    { $_[0]->{up} }
sub set_up    { $_[0]->{up} = $_[1] }

sub get_down  { $_[0]->{down} }
sub set_down  { $_[0]->{down} = $_[1] }

1;