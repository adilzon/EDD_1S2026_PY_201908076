package ArbolAVL;

use strict;
use warnings;

# --- 1. Crear un Nodo de Médico ---
sub nuevo_nodo {
    my ($colegio, $nombre, $tipo, $depto, $password) = @_;
    return {
        colegio  => $colegio, # Esta será la clave de ordenamiento
        nombre   => $nombre,
        tipo     => $tipo,
        depto    => $depto,
        password => $password,
        izq      => undef,
        der      => undef,
        altura   => 1 # Empezamos con altura 1
    };
}

# --- FUNCIONES DE APOYO PARA EL BALANCEO ---

sub obtener_altura {
    my ($nodo) = @_;
    return defined($nodo) ? $nodo->{altura} : 0;
}

sub maximo {
    my ($a, $b) = @_;
    return ($a > $b) ? $a : $b;
}

sub obtener_balance {
    my ($nodo) = @_;
    return defined($nodo) ? (obtener_altura($nodo->{izq}) - obtener_altura($nodo->{der})) : 0;
}

# Rotación a la Derecha
sub rotar_derecha {
    my ($y) = @_;
    my $x = $y->{izq};
    my $T2 = $x->{der};

    $x->{der} = $y;
    $y->{izq} = $T2;

    $y->{altura} = maximo(obtener_altura($y->{izq}), obtener_altura($y->{der})) + 1;
    $x->{altura} = maximo(obtener_altura($x->{izq}), obtener_altura($x->{der})) + 1;

    return $x;
}

# Rotación a la Izquierda
sub rotar_izquierda {
    my ($x) = @_;
    my $y = $x->{der};
    my $T2 = $y->{izq};

    $y->{izq} = $x;
    $x->{der} = $T2;

    $x->{altura} = maximo(obtener_altura($x->{izq}), obtener_altura($x->{der})) + 1;
    $y->{altura} = maximo(obtener_altura($y->{izq}), obtener_altura($y->{der})) + 1;

    return $y;
}

# --- 2. Insertar con Balanceo ---
sub insertar {
    my ($nodo, $nuevo) = @_;

    if (!defined($nodo)) {
        return $nuevo;
    }

    if ($nuevo->{colegio} lt $nodo->{colegio}) {
        $nodo->{izq} = insertar($nodo->{izq}, $nuevo);
    } elsif ($nuevo->{colegio} gt $nodo->{colegio}) {
        $nodo->{der} = insertar($nodo->{der}, $nuevo);
    } else {
        return $nodo; # Ya existe, no se duplica
    }

    # Actualizar altura del nodo padre
    $nodo->{altura} = 1 + maximo(obtener_altura($nodo->{izq}), obtener_altura($nodo->{der}));

    # Calcular el factor de balance
    my $balance = obtener_balance($nodo);

    # Casos de desbalanceo (Rotaciones)
    
    # Caso Izquierda-Izquierda
    if ($balance > 1 && $nuevo->{colegio} lt $nodo->{izq}->{colegio}) {
        return rotar_derecha($nodo);
    }

    # Caso Derecha-Derecha
    if ($balance < -1 && $nuevo->{colegio} gt $nodo->{der}->{colegio}) {
        return rotar_izquierda($nodo);
    }

    # Caso Izquierda-Derecha
    if ($balance > 1 && $nuevo->{colegio} gt $nodo->{izq}->{colegio}) {
        $nodo->{izq} = rotar_izquierda($nodo->{izq});
        return rotar_derecha($nodo);
    }

    # Caso Derecha-Izquierda
    if ($balance < -1 && $nuevo->{colegio} lt $nodo->{der}->{colegio}) {
        $nodo->{der} = rotar_derecha($nodo->{der});
        return rotar_izquierda($nodo);
    }

    return $nodo;
}

1;