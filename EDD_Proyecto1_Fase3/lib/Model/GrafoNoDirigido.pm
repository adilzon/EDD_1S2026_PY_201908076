#!/usr/bin/perl
use strict;
use warnings;

package Model::GrafoNoDirigido;

sub new {
    my $class = shift;
    my $self = {
        # Lista de adyacencia usando un hash de hashes para mayor eficiencia
        # clave: numero_colegio
        # valor: hash de adyacencias
        adyacencia     => {},
        nombres        => {}, # Guardará el nombre asociado a cada ID
        departamentos  => {}, # Guardará el departamento asociado a cada ID
        solicitudes    => {}, # Cola de solicitudes por receptor: { receptor => [solicitante1, ...] }
    };
    bless $self, $class;
    return $self;
}

sub insertar_vertice {
    my ($self, $id, $nombre, $departamento) = @_;
    if (!exists $self->{adyacencia}{$id}) {
        $self->{adyacencia}{$id} = {};
        $self->{nombres}{$id} = $nombre || $id;
        $self->{departamentos}{$id} = $departamento || 'SIN-DEP';
        $self->{solicitudes}{$id} = [];
    } else {
        # Actualizar datos si ya existe el nodo (por ejemplo, si se carga de nuevo o se le asigna dep)
        $self->{nombres}{$id} = $nombre if defined $nombre;
        $self->{departamentos}{$id} = $departamento if defined $departamento;
    }
}

sub insertar_arista {
    my ($self, $id1, $id2) = @_;
    
    # Si intentan conectarse a sí mismos
    return if $id1 eq $id2;

    # Asegurar que ambos vértices existan
    $self->insertar_vertice($id1);
    $self->insertar_vertice($id2);
    
    # Agregar la conexión bidireccional
    $self->{adyacencia}{$id1}{$id2} = 1;
    $self->{adyacencia}{$id2}{$id1} = 1;
}

sub agregar_solicitud {
    my ($self, $solicitante, $receptor) = @_;
    
    # Asegurar vértices
    $self->insertar_vertice($solicitante);
    $self->insertar_vertice($receptor);
    
    # Evitar duplicados
    foreach my $sol (@{$self->{solicitudes}{$receptor}}) {
        return if $sol eq $solicitante;
    }
    
    push @{$self->{solicitudes}{$receptor}}, $solicitante;
}

sub obtener_solicitudes {
    my ($self, $id) = @_;
    return $self->{solicitudes}{$id} || [];
}

sub responder_solicitud {
    my ($self, $solicitante, $receptor, $respuesta) = @_;
    
    # Filtrar la solicitud (quitarla de la lista)
    my @pendientes = @{$self->{solicitudes}{$receptor} || []};
    $self->{solicitudes}{$receptor} = [ grep { $_ ne $solicitante } @pendientes ];
    
    # Si acepta, crear arista
    if ($respuesta eq 'ACTIVA' || $respuesta eq 'ACEPTADA') {
        $self->insertar_arista($solicitante, $receptor);
        return 1;
    }
    return 0; # Rechazada
}

sub obtener_sugerencias {
    my ($self, $id) = @_;
    return [] unless exists $self->{adyacencia}{$id};
    
    my %sugerencias_count;
    my $contactos_directos = $self->{adyacencia}{$id};
    
    # Para cada contacto directo
    foreach my $contacto (keys %$contactos_directos) {
        # Para cada contacto del contacto (vecino de vecino)
        my $contactos_del_contacto = $self->{adyacencia}{$contacto};
        foreach my $c2 (keys %$contactos_del_contacto) {
            # No sugerir al mismo usuario, ni a los que ya son contactos directos
            if ($c2 ne $id && !exists $contactos_directos->{$c2}) {
                $sugerencias_count{$c2}++;
            }
        }
    }
    
    # Filtrar aquellos con 2 o más en común
    my @sugerencias_finales;
    foreach my $sug (keys %sugerencias_count) {
        if ($sugerencias_count{$sug} >= 2) {
            push @sugerencias_finales, {
                numero_colegio => $sug,
                comunes => $sugerencias_count{$sug}
            };
        }
    }
    
    # Ordenar de mayor a menor cantidad de contactos en común
    @sugerencias_finales = sort { $b->{comunes} <=> $a->{comunes} } @sugerencias_finales;
    
    return \@sugerencias_finales;
}

sub obtener_aislados {
    my ($self) = @_;
    my @aislados;
    foreach my $id (keys %{$self->{adyacencia}}) {
        if (scalar(keys %{$self->{adyacencia}{$id}}) == 0) {
            push @aislados, $id;
        }
    }
    return \@aislados;
}

sub exportar_grafo {
    my ($self) = @_;
    my @nodes;
    my @edges;
    my %aristas_vistas;
    
    foreach my $id (keys %{$self->{adyacencia}}) {
        my $nombre_etiqueta = $self->{nombres}{$id} || $id;
        my $depto = $self->{departamentos}{$id} || 'SIN-DEP';
        
        # Si tiene nombre, podemos mostrar el ID seguido del nombre
        my $label_final = "$id\n$nombre_etiqueta\n($depto)";
        push @nodes, { id => $id, label => $label_final, group => $depto };
        
        foreach my $vecino (keys %{$self->{adyacencia}{$id}}) {
            # Evitar aristas duplicadas en el JSON
            my $arista_id = $id lt $vecino ? "$id-$vecino" : "$vecino-$id";
            if (!exists $aristas_vistas{$arista_id}) {
                $aristas_vistas{$arista_id} = 1;
                push @edges, { from => $id, to => $vecino };
            }
        }
    }
    
    return { nodes => \@nodes, edges => \@edges };
}

sub reporte_adyacencia {
    my ($self) = @_;
    # Devuelve el hash de adyacencias completo para poder mostrarlo
    return $self->{adyacencia};
}

1;
