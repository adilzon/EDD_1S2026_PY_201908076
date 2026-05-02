package Model::TablaHash;

use strict;
use warnings;
use utf8;

sub new {
    my $class = shift;
    my $self = {
        tabla => {},           # clave = tipo_usuario (TIPO-01, TIPO-02, etc.)
        size  => 10,           # tamaño inicial de buckets
    };
    bless $self, $class;
    return $self;
}

# Insertar un usuario según su tipo
sub insertar {
    my ($self, $usuario) = @_;
    my $tipo = $usuario->{tipo_usuario} || $usuario->{tipo} || 'SIN_TIPO';
    
    if (!exists $self->{tabla}{$tipo}) {
        $self->{tabla}{$tipo} = [];
    }
    
    push @{$self->{tabla}{$tipo}}, $usuario;
    return 1;
}

# Obtener todos los usuarios de un tipo específico
sub obtener_por_tipo {
    my ($self, $tipo) = @_;
    return $self->{tabla}{$tipo} || [];
}

# Obtener todos los tipos disponibles
sub obtener_tipos {
    my $self = shift;
    return sort keys %{$self->{tabla}};
}

# Mostrar estado de la tabla hash (para reporte)
sub estado {
    my $self = shift;
    my $info = {};
    foreach my $tipo (keys %{$self->{tabla}}) {
        $info->{$tipo} = scalar @{$self->{tabla}{$tipo}};
    }
    return $info;
}

1;