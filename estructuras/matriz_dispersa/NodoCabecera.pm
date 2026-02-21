package matriz_dispersa::NodoCabecera;

use strict;
use warnings;

sub new {
    my ($class, $label) = @_;
    my $self = {
        label => $label,
        next  => undef,
        right => undef,  # para filas
        down  => undef,  # para columnas
    };
    bless $self, $class;
    return $self;
}

sub get_label { $_[0]->{label} }
sub get_next  { $_[0]->{next} }
sub set_next  { $_[0]->{next} = $_[1] }

sub get_right { $_[0]->{right} }
sub set_right { $_[0]->{right} = $_[1] }

sub get_down  { $_[0]->{down} }
sub set_down  { $_[0]->{down} = $_[1] }

1;