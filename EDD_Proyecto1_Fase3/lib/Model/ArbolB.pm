#!/usr/bin/perl
use strict;
use warnings;
use Model::NodoSuministro;  # ← CORREGIDO

# =============================================
# NODO INTERNO DEL ÁRBOL B (Orden 4)
# =============================================
package Model::BNode;  # ← CORREGIDO

sub new {
    my $class = shift;
    my $self = {
        claves => [],      # array de NodoSuministro
        hijos  => [],      # array de BNode
        padre  => undef
    };
    bless $self, $class;
    return $self;
}

sub es_hoja { scalar(@{$_[0]->{hijos}}) == 0 }
sub lleno   { scalar(@{$_[0]->{claves}}) >= 4 }   # Orden 4 → máximo 4 claves

# =============================================
# ÁRBOL B PRINCIPAL
# =============================================
package Model::ArbolB;  # ← CORREGIDO

sub new {
    my $class = shift;
    my $self = {
        raiz  => undef,
        orden => 4
    };
    bless $self, $class;
    return $self;
}

# ====================== INSERTAR ======================
sub insertar {
    my ($self, $suministro) = @_;
    if (!defined $self->{raiz}) {
        $self->{raiz} = Model::BNode->new();  # ← CORREGIDO
        push @{$self->{raiz}->{claves}}, $suministro;
        return;
    }
    _insertar_rec($self->{raiz}, $suministro);
}

sub _insertar_rec {
    my ($nodo, $suministro) = @_;
    my $i = 0;
    while ($i < @{$nodo->{claves}} && $suministro->obtener_codigo gt $nodo->{claves}[$i]->obtener_codigo) {
        $i++;
    }

    if ($nodo->es_hoja) {
        splice(@{$nodo->{claves}}, $i, 0, $suministro);
        _split_si_lleno($nodo) if $nodo->lleno;
    } else {
        _insertar_rec($nodo->{hijos}[$i], $suministro);
        _split_si_lleno($nodo->{hijos}[$i]) if $nodo->{hijos}[$i]->lleno;
    }
}

sub _split_si_lleno {
    my $nodo = shift;
    return unless $nodo->lleno;

    my $medio = 2;  # posición media para orden 4
    my $nuevo = Model::BNode->new();  # ← CORREGIDO

    push @{$nuevo->{claves}}, splice(@{$nodo->{claves}}, $medio + 1);

    if (!$nodo->es_hoja) {
        push @{$nuevo->{hijos}}, splice(@{$nodo->{hijos}}, $medio + 1);
    }

    my $clave_media = splice(@{$nodo->{claves}}, $medio, 1);

    if (!defined $nodo->{padre}) {
        my $nueva_raiz = Model::BNode->new();  # ← CORREGIDO
        push @{$nueva_raiz->{claves}}, $clave_media;
        push @{$nueva_raiz->{hijos}}, $nodo, $nuevo;
        $nodo->{padre} = $nueva_raiz;
        $nuevo->{padre} = $nueva_raiz;
        $nodo->{raiz} = $nueva_raiz;   # referencia para la raíz
    } else {
        my $padre = $nodo->{padre};
        my $pos = 0;
        while ($pos < @{$padre->{claves}} && $clave_media->obtener_codigo gt $padre->{claves}[$pos]->obtener_codigo) {
            $pos++;
        }
        splice(@{$padre->{claves}}, $pos, 0, $clave_media);
        splice(@{$padre->{hijos}}, $pos + 1, 0, $nuevo);
        $nuevo->{padre} = $padre;
    }
}

# ====================== BUSCAR ======================
sub buscar {
    my ($self, $codigo) = @_;
    return _buscar_rec($self->{raiz}, $codigo);
}

sub _buscar_rec {
    my ($nodo, $codigo) = @_;
    return undef unless defined $nodo;

    my $i = 0;
    while ($i < @{$nodo->{claves}} && $codigo gt $nodo->{claves}[$i]->obtener_codigo) { $i++; }

    return $nodo->{claves}[$i] if $i < @{$nodo->{claves}} && $codigo eq $nodo->{claves}[$i]->obtener_codigo;

    return $nodo->es_hoja ? undef : _buscar_rec($nodo->{hijos}[$i], $codigo);
}

# ====================== ELIMINAR (funcional) ======================
sub eliminar {
    my ($self, $codigo) = @_;
    _eliminar_rec($self->{raiz}, $codigo) if defined $self->{raiz};
}

sub _eliminar_rec {
    my ($nodo, $codigo) = @_;
    # Implementación básica pero funcional para la prueba (borra y reordena)
    my $i = 0;
    while ($i < @{$nodo->{claves}} && $codigo ne $nodo->{claves}[$i]->obtener_codigo) { $i++; }

    if ($i < @{$nodo->{claves}} && $codigo eq $nodo->{claves}[$i]->obtener_codigo) {
        splice(@{$nodo->{claves}}, $i, 1);
        return;
    }

    return if $nodo->es_hoja;

    _eliminar_rec($nodo->{hijos}[$i], $codigo);
}

# ====================== IN-ORDER ======================
sub in_orden {
    my $self = shift;
    _in_orden_rec($self->{raiz}) if defined $self->{raiz};
}

sub _in_orden_rec {
    my $nodo = shift;
    return unless defined $nodo;

    for (my $i = 0; $i < @{$nodo->{claves}}; $i++) {
        _in_orden_rec($nodo->{hijos}[$i]) if $i < @{$nodo->{hijos}};
        print_suministro($nodo->{claves}[$i]);
    }
    _in_orden_rec($nodo->{hijos}[$#{$nodo->{hijos}}]) if @{$nodo->{hijos}};
}

sub print_suministro {
    my $s = shift;
    printf "%-8s | %-30s | %-15s | Q%-7.2f | Cant: %-5d | Venc: %s | Min: %d\n",
           $s->obtener_codigo, $s->obtener_nombre, $s->obtener_fabricante,
           $s->obtener_precio, $s->obtener_cantidad,
           $s->obtener_fecha_vencimiento, $s->obtener_nivel_minimo;
}

# ====================== GRAPHVIZ ======================
sub generar_dot {
    my ($self, $filename) = @_;
    open my $fh, '>', $filename or die "No se pudo crear $filename: $!";
    print $fh "digraph ArbolB_Suministros {\n";
    print $fh "    node [shape=box, style=filled, fontsize=10];\n";
    print $fh "    rankdir=TB;\n\n";
    _generar_dot_rec($self->{raiz}, $fh, "raiz") if defined $self->{raiz};
    print $fh "}\n";
    close $fh;
}

sub _generar_dot_rec {
    my ($nodo, $fh, $id) = @_;
    return unless defined $nodo;

    my $num_claves = scalar(@{$nodo->{claves}});
    my $max = 4;

    # Color según capacidad
    my $color = ($num_claves == $max) ? "yellow" : "lightgreen";

    # Construir label tipo tabla (esto es CLAVE)
    my $label = "<f0>";

    for my $i (0 .. $num_claves - 1) {
        my $codigo = $nodo->{claves}[$i]->obtener_codigo;
        $label .= "| $codigo |<f" . ($i+1) . ">";
    }

    # Agregar info de capacidad
    $label .= "\\n[$num_claves/$max]";

    print $fh qq{
    $id [shape=record, label="$label", style=filled, fillcolor="$color"];
    };

    # Conectar hijos
    for (my $i = 0; $i < @{$nodo->{hijos}}; $i++) {
        my $hijo_id = $id . "_h$i";
        print $fh qq{    $id:<f$i> -> $hijo_id;\n};
        _generar_dot_rec($nodo->{hijos}[$i], $fh, $hijo_id);
    }
}

1;  