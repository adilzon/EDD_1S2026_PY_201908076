package Proveedor;

use strict;
use warnings;

use ListaEntregas;
use ListaInventario;

my $contador_proveedores = 0;

# =========================================
# Crear proveedor (indice automatico)
# =========================================
sub crear {
    my ($codigo, $nombre, $telefono) = @_;

    my $self = {
        codigo    => $codigo,
        nombre    => $nombre,
        telefono  => $telefono,
        indice    => $contador_proveedores,  # indice automatico (fila matriz)
        siguiente => undef,
        anterior  => undef,
        entregas  => undef,                  # lista simple de entregas
    };

    $contador_proveedores++;
    return $self;
}

# =========================================
# Agregar entrega a proveedor
# - inserta en lista
# - actualiza inventario
# - actualiza matriz dispersa (indirectamente)
# =========================================
sub agregar_entrega {
    my ($proveedor, $entrega) = @_;

    # 1. Insertar entrega en la lista del proveedor
    ListaEntregas::insertar($proveedor, $entrega);

    # 2. Buscar medicamento en inventario
    my $med = ListaInventario::buscar_por_nombre($entrega->{medicamento});

    if ($med) {
        # 3. Actualizar stock
        $med->{cantidad} += $entrega->{cantidad};

        print "\nEntrega registrada correctamente\n";
        print "Proveedor: $proveedor->{nombre}\n";
        print "Medicamento: $entrega->{medicamento}\n";
        print "Cantidad agregada: $entrega->{cantidad}\n";
        print "Nuevo stock: $med->{cantidad}\n";
    }
    else {
        print "\nAdvertencia: Medicamento '$entrega->{medicamento}' no existe en inventario\n";
    }
}

1;