#!/usr/bin/perl
use strict;
use warnings;

package Model::NodoPersonal;

sub new {
    my ($class, $numero_colegio, $nombre_completo, $tipo_usuario, $departamento, $especialidad, $contrasena) = @_;

    my $self = {
        numero_colegio  => $numero_colegio,
        nombre_completo => $nombre_completo,
        tipo_usuario    => $tipo_usuario,
        departamento    => $departamento,
        especialidad    => $especialidad || "N/A",
        contrasena      => $contrasena,
        izquierda       => undef,
        derecha         => undef,
        altura          => 1
    };

    bless $self, $class;
    return $self;
}

# Getters
sub obtener_numero_colegio { $_[0]->{numero_colegio}; }
sub obtener_nombre        { $_[0]->{nombre_completo}; }
sub obtener_tipo          { $_[0]->{tipo_usuario}; }
sub obtener_departamento  { $_[0]->{departamento}; }
sub obtener_especialidad  { $_[0]->{especialidad}; }
sub obtener_contrasena    { $_[0]->{contrasena}; }
sub obtener_altura        { $_[0]->{altura}; }

# Setters para balanceo
sub set_altura {
    my ($self, $nueva) = @_;
    $self->{altura} = $nueva;
}

1;